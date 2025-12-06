defmodule Benchmark do
  @moduledoc """
  Помощен модул за измерване.
  """

  @doc """
  Измерва броя итерации, необходими за постигане на целева точност.
  """
  def measure_accuracy(module, function, target_value, tolerance \\ 0.001, max_iterations \\ 100_000) do
    # Първо намираме горна граница където точността е постигната
    case find_upper_bound(module, function, target_value, tolerance, 1, max_iterations) do
      {:not_found, last_n, last_result} ->
        error = abs(last_result - target_value)
        %{
          achieved: false,
          iterations: last_n,
          result: last_result,
          target: target_value,
          error: error,
          message: "Не може да се постигне целевата точност до #{max_iterations} итерации"
        }

      upper_bound ->
        # Използваме binary search за намиране на минималния брой итерации
        binary_search_minimum(module, function, target_value, tolerance, 1, upper_bound)
    end
  end

  # Намира горна граница с експоненциален растеж
  defp find_upper_bound(module, function, target_value, tolerance, current_n, max_n) when current_n <= max_n do
    {_time, result} = :timer.tc(module, function, [current_n])
    error = abs(result - target_value)

    if error <= tolerance do
      current_n
    else
      next_n = min(round(current_n * 1.5), max_n)

      if next_n > current_n do
        find_upper_bound(module, function, target_value, tolerance, next_n, max_n)
      else
        {:not_found, current_n, result}
      end
    end
  end

  defp find_upper_bound(module, function, _target_value, _tolerance, _current_n, max_n) do
    {_time, result} = :timer.tc(module, function, [max_n])
    {:not_found, max_n, result}
  end

  # Binary search за намиране на минималния брой итерации
  defp binary_search_minimum(module, function, target_value, tolerance, low, high) when low < high do
    mid = div(low + high, 2)
    {_time, result} = :timer.tc(module, function, [mid])
    error = abs(result - target_value)

    if error <= tolerance do
      # Точността е постигната при mid, проверяваме дали има по-малко
      binary_search_minimum(module, function, target_value, tolerance, low, mid)
    else
      # Точността не е постигната, търсим нагоре
      binary_search_minimum(module, function, target_value, tolerance, mid + 1, high)
    end
  end

  defp binary_search_minimum(module, function, target_value, tolerance, low, high) when low == high do
    {time, result} = :timer.tc(module, function, [low])
    error = abs(result - target_value)

    %{
      iterations: low,
      result: result,
      target: target_value,
      error: error,
      time_microseconds: time,
      achieved: error <= tolerance
    }
  end

  @doc """
  Измерва дълбочината на рекурсията.
  За модул Pi, дълбочината на рекурсията = n (брой членове).
  """
  def measure_recursion_depth(n) do
    %{
      input_n: n,
      recursion_depth: n,
    }
  end

  @doc """
  Измерва скоростта на изпълнение: операции в секунда, време на итерация.
  """
  def measure_speed(module, function, n) do
    {time, result} = :timer.tc(module, function, [n])

    %{
      total_time_milliseconds: time / 1000,
      result: result
    }
  end
end
