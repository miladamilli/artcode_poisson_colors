defmodule PoissonColors.Style do
  @moduledoc """
  Generates style of SVG circle.
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
    hue_min = max(hue - variation, 0)
    hue_max = min(hue + variation, 360)
    random(hue_min, hue_max)
  end

  def random_saturation(value, variation), do: random_saturation_lightness(value, variation)
  def random_lightness(value, variation), do: random_saturation_lightness(value, variation)

  def random_saturation_lightness(value, variation) do
    value_min = max(value - variation, 0)
    value_max = min(value + variation, 100)
    random(value_min, value_max)
  end

  def random_opacity(opacity, variation) do
    min = max(opacity - variation, 0)
    max = min(opacity + variation, 1)
    min = floor(min * 10)
    max = floor(max * 10)
    random(min, max) / 10
  end

  def random_radius(%{
        size: size,
        size_variation: variation,
        size_min: size_min,
        size_max: size_max
      }) do
    min = max(size - variation, size_min)
    max = min(size + variation, size_max)
    random(div(min, 2), div(max, 2))
  end

  defp random(from, to) do
    :rand.uniform(to - from + 1) + from - 1
  end
end
