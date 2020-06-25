defmodule PoissonColors.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PoissonColorsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PoissonColors.PubSub},
      # Start the Endpoint (http/https)
      PoissonColorsWeb.Endpoint
      # Start a worker by calling: PoissonColors.Worker.start_link(arg)
      # {PoissonColors.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PoissonColors.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PoissonColorsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
