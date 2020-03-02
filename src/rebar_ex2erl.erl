-module(rebar_ex2erl).
-behaviour(provider).
-export([init/1, do/1, format_error/1, ex2erl/2]).

-define(PROVIDER, compile).
-define(NAMESPACE, ex2erl).
-define(DEPS, [{default, compile}]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
        {name, ?PROVIDER},
        {namespace, ?NAMESPACE},
        {module, ?MODULE},
        {bare, true},
        {deps, ?DEPS},
        {example, "rebar3 ex2erl compile"},
        {opts, []},
        {short_desc, "An example rebar compile plugin"},
        {desc, ""}
    ]),
    {ok, rebar_state:add_provider(State, Provider)}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    Apps = case rebar_state:current_app(State) of
        undefined ->
            rebar_state:project_apps(State);
        AppInfo ->
            [AppInfo]
        end,
    [begin
         Opts = rebar_app_info:opts(AppInfo),
         OutDir = filename:join(rebar_app_info:dir(AppInfo), "src"),
         SourceDir = filename:join(rebar_app_info:dir(AppInfo), "src"),
         FoundFiles = rebar_utils:find_files(SourceDir, ".*\\.ex\$"),

         CompileFun = fun(Source, Opts1) ->
             ex2erl_compile(Opts1, Source, OutDir)
         end,

         rebar_base_compiler:run(Opts, [], FoundFiles, CompileFun)
     end || AppInfo <- Apps],

    {ok, State}.

format_error(Reason) ->
    io_lib:format("~p", [Reason]).

ex2erl_compile(_Opts, Source, OutDir) ->
    {ok, ElixirCode} = file:read_file(Source),
    OutFile = filename:join([OutDir, filename:basename(Source, ".ex") ++ ".erl"]),
    filelib:ensure_dir(OutFile),
    rebar_api:info("Writing out ~s", [OutFile]),
    [{Module, ErlangCode}] = ex2erl(ElixirCode, OutFile),
    file:write_file(OutFile, ErlangCode),
    %% unload module
    code:purge(Module),
    code:delete(Module),
    ok.

ex2erl(Code, File) when is_binary(Code), is_list(File) ->
    ensure_elixir(),
    Result = 'Elixir.Code':compile_string(Code, list_to_binary(File)),
    lists:map(fun({Mod, Beam}) -> {Mod, iolist_to_binary(code(Beam))} end, Result).

code(Beam) ->
    {ok, {_, [{abstract_code, {_, AC}}]}} = beam_lib:chunks(Beam, [abstract_code]),
    Header = "%% generated by ex2erl, do not edit manuaally\n",
    [Header | lists:map(fun pp/1, AC)].

%% pretty-print a form. Removes things that the compiler automatically adds like the __info__/1
%% function.
pp({function, _, '__info__', _, _}) -> [];
pp({attribute, _, spec, {{'__info__', 1}, _}}) -> [];
pp({attribute, _, export, Exports} = Form) ->
    NewExports = proplists:delete('__info__', Exports),
    NewForm = setelement(4, Form, NewExports),
    erl_pp:form(NewForm);
pp(Form) -> erl_pp:form(Form).

ensure_elixir() ->
    case code:is_loaded('Elixir.Kernel') of
        {file, _} ->
            ok;
        false ->
            case os:find_executable("elixir") of
                false -> error("");
                _ -> ok
            end,
            KernelBeamPath = os:cmd("elixir -e \"IO.write :code.which(Kernel)\""),
            ElixirEbin = filename:dirname(KernelBeamPath),
            code:add_patha(ElixirEbin),
            application:ensure_all_started(elixir)
    end.