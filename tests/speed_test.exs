# Зареждане на необходимите модули
Code.require_file("../leibniz.exs", __DIR__)
Code.require_file("../wallis.exs", __DIR__)
Code.require_file("../nilakantha.exs", __DIR__)
Code.require_file("benchmark.exs", __DIR__)

defmodule PiSpeedTest do
  @moduledoc """
  Тест за скорост на различните алгоритми за приближение на π.
  """

  def run do
    IO.puts("\n=== ТЕСТ ЗА СКОРОСТ НА АЛГОРИТМИ ЗА ПРИБЛИЖЕНИЕ НА π ===\n")

    target_pi = :math.pi()
    test_iterations = 100_000

    algorithms = [
      {"Leibniz (Рекурсивен)", PiLeibniz, :leibniz_recursive},
      {"Leibniz (Итеративен)", PiLeibniz, :leibniz_iterative},
      {"Wallis (Рекурсивен)", PiWallis, :wallis_recursive},
      {"Wallis (Итеративен)", PiWallis, :wallis_iterative},
      {"Nilakantha (Рекурсивен)", PiNilakantha, :nilakantha_recursive},
      {"Nilakantha (Итеративен)", PiNilakantha, :nilakantha_iterative}
    ]

    results =
      Enum.map(algorithms, fn {name, module, function} ->
        IO.puts("Тестване: #{name}...")

        # Измерване на скоростта с фиксиран брой итерации
        speed = Benchmark.measure_speed(module, function, test_iterations)

        # Измерване на дълбочината на рекурсията
        recursion = Benchmark.measure_recursion_depth(test_iterations)

        %{
          name: name,
          speed_time_ms: speed.total_time_milliseconds,
          speed_result: speed.result,
          recursion_depth: recursion.recursion_depth
        }
      end)

    print_speed_table(results, target_pi, test_iterations)
  end

  defp print_speed_table(results, target_pi, test_iterations) do
    IO.puts("\n╔═══ ТЕСТ ЗА СКОРОСТ (#{test_iterations} итерации) ═══╗")
    IO.puts(String.duplicate("=", 120))
    IO.puts(
      String.pad_trailing("Алгоритъм", 30) <>
        " | " <>
        String.pad_trailing("Време (ms)", 15) <>
        " | " <>
        String.pad_trailing("Резултат", 15) <>
        " | " <>
        String.pad_trailing("Грешка", 15) <>
        " | " <>
        String.pad_trailing("Дълбочина", 15)
    )
    IO.puts(String.duplicate("=", 120))

    Enum.each(results, fn result ->
      error = abs(result.speed_result - target_pi)

      IO.puts(
        String.pad_trailing(result.name, 30) <>
          " | " <>
          String.pad_trailing("#{Float.round(result.speed_time_ms, 2)}", 15) <>
          " | " <>
          String.pad_trailing("#{Float.round(result.speed_result, 10)}", 15) <>
          " | " <>
          String.pad_trailing("#{Float.round(error, 10)}", 15) <>
          " | " <>
          String.pad_trailing("#{result.recursion_depth}", 15)
      )
    end)

    IO.puts(String.duplicate("=", 120) <> "\n")
    IO.puts("Целева стойност на π: #{Float.round(target_pi, 10)}\n")
  end
end

# Стартиране на теста
PiSpeedTest.run()
