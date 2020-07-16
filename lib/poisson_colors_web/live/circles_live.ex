defmodule PoissonColorsWeb.CirclesLive do
  @moduledoc """
  Generates colorful circles using Poisson Disc Sampling algorithm.
  """
  use PoissonColorsWeb, :live_view_fullscreen
  alias PoissonColors.Style
  alias PoissonDiscSampling

  @export_template "lib/poisson_colors_web/templates/svg_template.eex"
  @path "priv/output/"

  @canvas_w 1920
  @canvas_h 1080
  @samples 10
  @color %{
    hue: 180,
    hue_variation: 180,
    saturation: 75,
    saturation_variation: 25,
    lightness: 65,
    lightness_variation: 13,
    opacity: 0.5,
    opacity_variation: 1.0
  }

  def mount(_params, _session, socket) do
    settings = %{
      min_dist: 80,
      color: @color,
      size: 60,
      size_variation: 60,
      size_min: 5,
      size_max: 250
    }

    socket =
      assign(socket,
        canvas_w: @canvas_w,
        canvas_h: @canvas_h,
        settings: settings,
        background: "white",
        page_title: "Poisson & Colors"
      )

    if connected?(socket) do
      {:ok, assign(socket, objects: generate_objects(settings))}
    else
      {:ok, assign(socket, objects: [])}
    end
  end

  def handle_event("settings", %{"min_dist" => min_dist}, socket) do
    min_dist = String.to_integer(min_dist)
    settings = %{socket.assigns.settings | min_dist: min_dist}

    {:noreply, assign(socket, objects: generate_objects(settings), settings: settings)}
  end

  def handle_event("color", color, socket) do
    color =
      color
      |> Map.delete("_target")
      |> Map.new(fn {k, v} -> {String.to_existing_atom(k), parse_number(v)} end)

    settings = %{socket.assigns.settings | color: Map.merge(socket.assigns.settings.color, color)}

    {:noreply,
     assign(socket,
       settings: settings,
       objects: re_generate_objects(socket.assigns.objects, settings)
     )}
  end

  def handle_event("size", %{"size" => size, "size_variation" => size_variation}, socket) do
    size = String.to_integer(size)
    size_variation = String.to_integer(size_variation)
    settings = %{socket.assigns.settings | size: size, size_variation: size_variation}

    {:noreply,
     assign(socket,
       objects: re_generate_objects(socket.assigns.objects, settings),
       settings: settings
     )}
  end

  def handle_event("background", %{"background" => color}, socket) do
    {:noreply, assign(socket, background: color)}
  end

  def handle_event("save", _, socket) do
    file_id = UUID.uuid1()

    file = @path <> file_id
    generate_image(socket, file)

    {:noreply,
     socket
     |> put_flash(
       :info,
       Phoenix.HTML.raw(
         ~s(Image exported: <a href="#{file_id}.jpg" target="_blank">download link</a>.)
       )
     )}
  end

  defp generate_image(socket, file) do
    svg =
      EEx.eval_file(@export_template,
        objects: socket.assigns.objects,
        canvas_w: socket.assigns.canvas_w,
        canvas_h: socket.assigns.canvas_h,
        background: socket.assigns.background
      )

    File.write!(file <> ".svg", svg)
    System.cmd("convert", [file <> ".svg", file <> ".jpg"])
    File.rm!(file <> ".svg")
  end

  defp generate_objects(settings) do
    PoissonDiscSampling.generate(settings.min_dist, @canvas_w, @canvas_h, @samples)
    |> Enum.map(fn {x, y} -> %{x: x, y: y, style: Style.random(settings)} end)
  end

  defp re_generate_objects(objects, settings) do
    Enum.map(objects, fn object -> %{object | style: Style.random(settings)} end)
  end

  defp parse_number(number) do
    case Integer.parse(number) do
      {number, ""} -> number
      _ -> String.to_float(number)
    end
  end
end
