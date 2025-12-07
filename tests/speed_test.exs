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
    IO.puts("\n=== КОМБИНИРАН ТЕСТ ЗА СКОРОСТ НА АЛГОРИТМИ ЗА ПРИБЛИЖЕНИЕ НА π ===\n")

    target_pi = :math.pi()

    # Дефиниране на различни сценарии за тестване
    test_scenarios = [
      %{iterations: 1_000},
      %{iterations: 10_000},
      %{iterations: 100_000},
      %{iterations: 1_000_000}
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
      Enum.map(test_scenarios, fn scenario ->
        IO.puts("Тестване с #{scenario.iterations} итерации...")

        scenario_results =
          Enum.map(algorithms, fn {name, module, function} ->
            # Измерване на скоростта
            speed = Benchmark.measure_speed(module, function, scenario.iterations)

            # Измерване на дълбочината на рекурсията
            recursion = Benchmark.measure_recursion_depth(scenario.iterations)

            %{
              algorithm_name: name,
              iterations: scenario.iterations,
              time_ms: speed.total_time_milliseconds,
              result: speed.result,
              recursion_depth: recursion.recursion_depth
            }
          end)

        {scenario, scenario_results}
      end)

    print_combined_table(all_results, target_pi)
  end

  defp print_combined_table(all_results, target_pi) do
    IO.puts("\n╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗")
    IO.puts("║                                    ОБЕДИНЕНА ТАБЛИЦА С РЕЗУЛТАТИ ОТ ВСИЧКИ ТЕСТОВЕ                                              ║")
    IO.puts("╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝")
    IO.puts("\nЦелева стойност на π: #{Float.round(target_pi, 10)}\n")

    Enum.each(all_results, fn {scenario, results} ->
      IO.puts("\n#{String.duplicate("═", 160)}")
      IO.puts("  Брой итерации: #{scenario.iterations}")
      IO.puts(String.duplicate("═", 160))

      IO.puts(
        String.pad_trailing("Алгоритъм", 30) <>
          " | " <>
          String.pad_trailing("Итерации", 12) <>
          " | " <>
          String.pad_trailing("Време (ms)", 15) <>
          " | " <>
          String.pad_trailing("Резултат", 18) <>
          " | " <>
          String.pad_trailing("Грешка", 15) <>
          " | " <>
          String.pad_trailing("Дълбочина", 15)
      )
      IO.puts(String.duplicate("─", 160))

      Enum.each(results, fn result ->
        iterations_str = "#{result.iterations}"
        time_str = "#{Float.round(result.time_ms, 2)}"
        result_str = "#{Float.round(result.result, 10)}"
        error = abs(result.result - target_pi)
        error_str = "#{Float.round(error, 10)}"
        depth_str = "#{result.recursion_depth}"

        IO.puts(
          String.pad_trailing(result.algorithm_name, 30) <>
            " | " <>
            String.pad_trailing(iterations_str, 12) <>
            " | " <>
            String.pad_trailing(time_str, 15) <>
            " | " <>
            String.pad_trailing(result_str, 18) <>
            " | " <>
            String.pad_trailing(error_str, 15) <>
            " | " <>
            String.pad_trailing(depth_str, 15)
        )
      end)
    end)

    IO.puts("\n" <> String.duplicate("═", 160))
    print_summary(all_results)
  end

  defp print_summary(all_results) do
    IO.puts("\n╔═══ ОБОБЩЕНИЕ ═══╗\n")

    Enum.each(all_results, fn {scenario, results} ->
      avg_time = Enum.sum(Enum.map(results, & &1.time_ms)) / length(results)
      fastest = Enum.min_by(results, & &1.time_ms)
      slowest = Enum.max_by(results, & &1.time_ms)

      IO.puts("Брой итерации: #{scenario.iterations}")
      IO.puts("  ├─ Средно време: #{Float.round(avg_time, 2)} ms")
      IO.puts("  ├─ Най-бърз: #{fastest.algorithm_name} (#{Float.round(fastest.time_ms, 2)} ms)")
      IO.puts("  └─ Най-бавен: #{slowest.algorithm_name} (#{Float.round(slowest.time_ms, 2)} ms)")
      IO.puts("")
    end)
  end
end

# Стартиране на теста
PiSpeedTest.run()
