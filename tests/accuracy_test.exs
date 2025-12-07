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
    IO.puts("\n=== КОМБИНИРАН ТЕСТ ЗА ТОЧНОСТ НА АЛГОРИТМИ ЗА ПРИБЛИЖЕНИЕ НА π ===\n")

    target_pi = :math.pi()

    # Дефиниране на различни точности с множество max_iterations за всяка
    test_scenarios = [
      %{
        tolerance: 0.1,
        max_iterations_list: [100_000]
      },
      %{
        tolerance: 0.01,
        max_iterations_list: [100_000]
      },
      %{
        tolerance: 0.001,
        max_iterations_list: [100_000]
      },
      %{
        tolerance: 0.0001,
        max_iterations_list: [100_000]
      }
    ]

    algorithms = [
      {"Leibniz (Рекурсивен)", PiLeibniz, :leibniz_recursive},
      {"Leibniz (Итеративен)", PiLeibniz, :leibniz_iterative},
      {"Wallis (Рекурсивен)", PiWallis, :wallis_recursive},
      {"Wallis (Итеративен)", PiWallis, :wallis_iterative},
      {"Nilakantha (Рекурсивен)", PiNilakantha, :nilakantha_recursive},
      {"Nilakantha (Итеративен)", PiNilakantha, :nilakantha_iterative}
    ]

    # Изпълнение на всички тестове
    all_results =
      Enum.flat_map(test_scenarios, fn scenario ->
        Enum.map(scenario.max_iterations_list, fn max_iter ->
          IO.puts("Тестване с точност (±#{scenario.tolerance}), max: #{max_iter}...")

          scenario_results =
            Enum.map(algorithms, fn {name, module, function} ->
              accuracy = Benchmark.measure_accuracy(
                module,
                function,
                target_pi,
                scenario.tolerance,
                max_iter
              )

              Map.merge(accuracy, %{
                algorithm_name: name,
                tolerance: scenario.tolerance,
                max_iterations: max_iter
              })
            end)

          {scenario, max_iter, scenario_results}
        end)
      end)

    print_combined_table(all_results, target_pi)
  end

  defp print_combined_table(all_results, target_pi) do
    IO.puts("\n╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗")
    IO.puts("║                                    ОБЕДИНЕНА ТАБЛИЦА С РЕЗУЛТАТИ ОТ ВСИЧКИ ТЕСТОВЕ                                              ║")
    IO.puts("╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝")
    IO.puts("\nЦелева стойност на π: #{Float.round(target_pi, 10)}\n")

    Enum.each(all_results, fn {scenario, max_iter, results} ->
      IO.puts("\n#{String.duplicate("═", 150)}")
      IO.puts("  Целева точност: ±#{scenario.tolerance} | Max итерации: #{max_iter}")
      IO.puts(String.duplicate("═", 150))

      IO.puts(
        String.pad_trailing("Алгоритъм", 30) <>
          " | " <>
          String.pad_trailing("Целева точност", 16) <>
          " | " <>
          String.pad_trailing("Итерации", 12) <>
          " | " <>
          String.pad_trailing("Резултат", 18) <>
          " | " <>
          String.pad_trailing("Грешка", 15) <>
          " | " <>
          String.pad_trailing("Статус", 15)
      )
      IO.puts(String.duplicate("─", 150))

      Enum.each(results, fn result ->
        tolerance_str = "±#{result.tolerance}"
        iterations_str = "#{result.iterations}"
        result_str = "#{Float.round(result.result, 10)}"
        error_str = "#{Float.round(result.error, 10)}"

        achieved_str = if result.achieved do
          "✓ Постигната"
        else
          "✗ Не постигната"
        end

        IO.puts(
          String.pad_trailing(result.algorithm_name, 30) <>
            " | " <>
            String.pad_trailing(tolerance_str, 16) <>
            " | " <>
            String.pad_trailing(iterations_str, 12) <>
            " | " <>
            String.pad_trailing(result_str, 18) <>
            " | " <>
            String.pad_trailing(error_str, 15) <>
            " | " <>
            achieved_str
        )
      end)
    end)

    IO.puts("\n" <> String.duplicate("═", 150))
    print_summary(all_results)
  end

  defp print_summary(all_results) do
    IO.puts("\n╔═══ ОБОБЩЕНИЕ ═══╗\n")

    # Групиране по толеранс и max_iterations
    grouped = Enum.group_by(all_results, fn {scenario, max_iter, _} ->
      {scenario.tolerance, max_iter}
    end)

    Enum.each(grouped, fn {{tolerance, max_iter}, group} ->
      all_results_for_group = Enum.flat_map(group, fn {_, _, results} -> results end)
      successful = Enum.count(all_results_for_group, & &1.achieved)
      total = length(all_results_for_group)

      IO.puts("Точност ±#{tolerance} (max: #{max_iter}):")
      IO.puts("  └─ Успешни: #{successful}/#{total}")
    end)

    IO.puts("")
  end
end

# Стартиране на теста
PiAccuracyTest.run()
