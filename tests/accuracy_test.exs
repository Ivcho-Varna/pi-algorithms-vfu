# Зареждане на необходимите модули
Code.require_file("../leibniz.exs", __DIR__)
Code.require_file("../wallis.exs", __DIR__)
Code.require_file("../nilakantha.exs", __DIR__)
Code.require_file("benchmark.exs", __DIR__)

defmodule PiAccuracyTest do
  @moduledoc """
  Тест за точност на различните алгоритми за приближение на π.
  """

  def run do
    IO.puts("\n=== ТЕСТ ЗА ТОЧНОСТ НА АЛГОРИТМИ ЗА ПРИБЛИЖЕНИЕ НА π ===\n")

    target_pi = :math.pi()
    tolerance = 0.001
    max_iterations = 100_000

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

        # Измерване на необходимите итерации за постигане на точност
        accuracy = Benchmark.measure_accuracy(module, function, target_pi, tolerance, max_iterations)

        Map.merge(accuracy, %{name: name})
      end)

    print_accuracy_table(results, target_pi, tolerance)
  end

  defp print_accuracy_table(results, target_pi, tolerance) do
    IO.puts("\n╔═══ ТЕСТ ЗА ТОЧНОСТ (толеранс: ±#{tolerance}) ═══╗")
    IO.puts(String.duplicate("=", 120))
    IO.puts(
      String.pad_trailing("Алгоритъм", 30) <>
        " | " <>
        String.pad_trailing("Мин. итерации", 18) <>
        " | " <>
        String.pad_trailing("Резултат", 15) <>
        " | " <>
        String.pad_trailing("Грешка", 15) <>
        " | " <>
        String.pad_trailing("Статус", 20)
    )
    IO.puts(String.duplicate("=", 120))

    Enum.each(results, fn result ->
      iterations_str = "#{result.iterations}"
      result_str = "#{Float.round(result.result, 10)}"
      error_str = "#{Float.round(result.error, 10)}"

      achieved_str = if result.achieved do
        "✓ Постигната"
      else
        "✗ Не постигната"
      end

      IO.puts(
        String.pad_trailing(result.name, 30) <>
          " | " <>
          String.pad_trailing(iterations_str, 18) <>
          " | " <>
          String.pad_trailing(result_str, 15) <>
          " | " <>
          String.pad_trailing(error_str, 15) <>
          " | " <>
          achieved_str
      )
    end)

    IO.puts(String.duplicate("=", 120) <> "\n")
    IO.puts("Целева стойност на π: #{Float.round(target_pi, 10)}\n")
  end
end

# Стартиране на теста
PiAccuracyTest.run()
