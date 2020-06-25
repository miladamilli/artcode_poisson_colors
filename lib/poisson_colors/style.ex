defmodule PoissonColors.Style do
  @moduledoc """
  Generates style of SVG objects.
  """
  def random(%{color: color} = settings) do
    %{
      radius: random_radius(settings),
      hue: random_hue(color.hue, color.hue_variation),
      saturation: random_saturation(color.saturation, color.saturation_variation),
      lightness: random_lightness(color.lightness, color.lightness_variation),
      opacity: random_opacity(color.opacity, color.opacity_variation)
    }
  end

  def random_hue(hue, variation) do
    hue_min = hue - variation
    hue_min = if hue_min >= 0, do: hue_min, else: 0
    hue_max = hue + variation
    hue_max = if hue_max <= 360, do: hue_max, else: 360

    Enum.random(hue_min..hue_max)
  end

  def random_saturation(value, variation), do: random_saturation_lightness(value, variation)
  def random_lightness(value, variation), do: random_saturation_lightness(value, variation)

  def random_saturation_lightness(value, variation) do
    value_min = value - variation
    value_min = if value_min >= 0, do: value_min, else: 0
    value_max = value + variation
    value_max = if value_max <= 100, do: value_max, else: 100

    Enum.random(value_min..value_max)
  end

  def random_opacity(opacity, variation) do
    min = opacity - variation
    min = if min >= 0, do: min, else: 0
    max = opacity + variation
    max = if max <= 1, do: max, else: 1
    min = floor(min * 10)
    max = floor(max * 10)

    Enum.random(min..max) / 10
  end

  def random_radius(%{
        size: size,
        size_variation: variation,
        size_min: size_min,
        size_max: size_max
      }) do
    min = size - variation
    min = if min >= size_min, do: min, else: size_min
    max = size + variation
    max = if max <= size_max, do: max, else: size_max

    Enum.random(div(min, 2)..div(max, 2))
  end
end
