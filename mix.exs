defmodule OmniChat.Mixfile do
  use Mix.Project

  def project do
    [
      app: :omni_chat,
      version: "0.1.2",
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  def application do
    [
      mod: {OmniChat, []},
      applications: [
        :apex,
        :cowboy,
        :ex_twilio,
        :ex_twiml,
        :faker,
        :gettext,
        :ja_serializer,
        :logger,
        :phoenix_ecto,
        :phoenix_html,
        :phoenix_pubsub,
        :phoenix,
        :postgrex,
        :timex_ecto,
        :timex
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:ex_twilio, "~> 0.2.0"},
      {:ex_twiml, "~> 2.1.0"},
      {:gettext, "~> 0.11"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.2.1"},
      {:postgrex, ">= 0.0.0"},
      {:faker, "~> 0.5"},
      {:poison, "~> 2.0"},
      {:ja_serializer, "~> 0.10.1"},
      {:timex, "~> 3.0.5"},
      {:timex_ecto, "~> 3.0.3"},
      {:apex, "~>0.5.1"},
      {:exrm, "~> 1.0.8"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
    [
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs"
      ],
      "ecto.reset": [
        "ecto.drop",
        "ecto.setup"
      ],
     "test": [
       "ecto.create --quiet",
       "ecto.migrate",
       "test"
      ]
    ]
  end
end
