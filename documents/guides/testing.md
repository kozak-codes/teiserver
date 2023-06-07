## Testing
Run as above (`mix run --no-halt`) and load up Chobby. Set Chobby's server to `localhost`. In my experience it's then fastest to restart Chobby and it will connect to your locally running instance. After you've finished you'll want to set the server back to `road-flag.bnr.la`.

You can login using the normal login command but it's much easier to login using `LI <username>` which is currently in place for testing purposes. `test_data.ex` has a bunch of existing users for testing purposes but you can use the protocols `REGISTER username password email` command to create a new user. State is currently not persisted over restarts. If you are familiar with Elixir then starting it with `iex -S mix` will put it in console mode and you can execute commands through the modules there too.

## Integration tests
We have a separate project to perform integration tests on Teiserver called [Hailstorm](https://github.com/beyond-all-reason/hailstorm). All Hailstorm documentation is located on the Hailstorm repo.

## Debugging, Go-to-definition, documentation, and code completion in VSCode using ElixirLS

You can run the server in the visual studio code debugger using the [ElixirLS](https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls)  extension

For WSL users make sure Visual Studio Code is running using the WSL extention and is connected remotely to your WSL instance, for more info on how to do this consult [the relevant microsoft documentation](https://code.visualstudio.com/docs/remote/wsl).

Next in the teiserver root directory open VSCode with `code .`

In extensions you need to install [ElixirLS](https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls)

If you have no Terminal open go to Terminal>Run to open a terminal in VS Code then click on Debug Console to have access to the program output and the Interactive REPL mode while debugging

For ubuntu users, make sure you have erlang debugger installed otherwise you will get an error: `UndefinedFunctionError) function :int.interpretable/1 is undefined (module :int is not available)`.

If you are seeing an error such as "Failed to start / connect to elixir language server" make sure that elixir has been added to your PATH and that you have fully restarted VSCode.

If you are able to start VSCode with no elixir errors, you should have language features such as go-to-definition, documentation, and code completion.

### Debugging

A launch.json file is provided within the .vscode folder. Press F5 to start debugging the application - it may take awhile to start.
