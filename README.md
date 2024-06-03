# Engweb

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Setting up the bd

To setup the database you need to have postgres installed and running.

You need to have `gdown` installed to download the database dump.

To install `gdown` run:

```bash
pip install gdown
```

Then run the following command to download the database dump:

```bash
gdown https://drive.google.com/uc?id=1ZWrg_ARBkzlpKmMxs7oirQTnSMXzdzFw
```

After downloading the dump, you need to unzip the file to the empty folder `MapaRuas-materialBase` in the root of the project.

Then you can run the script python to create the json file that will be used to populate the database:

```bash
python3 scripts/xmlToJson.py
```

Finally, you can run the following command to create and populate the database:

```bash
mix ecto.setup
```