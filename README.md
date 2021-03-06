`rebar_ex2erl`
=====

A rebar plugin for translating Elixir files to Erlang equivalents.

## Installation

1. Create a new rebar3 project: `rebar3 new lib mylib`

2. Add plugin to your project's `rebar.config`:

   ```erlang
   %% rebar.config
   {plugins, [
     {rebar_ex2erl, {git, "git@github.com:wojtekmach/rebar_ex2erl.git"}}
   ]}.
   {provider_hooks, [
     {post, [{compile, {ex2erl, compile}}]}
   ]}.
   ```

3. Add an Elixir file with a module:

   ```elixir
   # src/foo.ex
   defmodule :foo do
     def hello() do
       :world
     end
   end
   ```

4. Compile your project: `rebar3 compile`

5. An Erlang file for your Elixir module has automatically been created:

   ```erlang
   %% generated by ex2erl, do not edit manuaally
   -file("src/foo.erl", 1).
   -module(foo).
   -compile([no_auto_import]).
   -export([hello/0]).
   hello() ->
       world.
   ```

## Similar projects

* <https://github.com/aerosol/decompilerl>
* <https://github.com/michalmuskala/decompile>
* <https://github.com/okeuday/reltool_util>

## License

Copyright (c) 2020 Wojciech Mach

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
in compliance with the License. You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License
is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied. See the License for the specific language governing permissions and limitations under
the License.
