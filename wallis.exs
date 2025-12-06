defmodule PiWallis do
  @moduledoc """
  Приближение на π чрез произведението на Wallis.
  """

  @doc """
  Рекурсивна реализация (не-опашкова).

  Формула на Wallis:
  π/2 = (2/1) * (2/3) * (4/3) * (4/5) * (6/5) * (6/7) * ...
  π = 2 * ∏[k=1 до n] (4k²) / (4k² - 1)
  """
  def wallis_recursive(n) when n > 0 do
    2.0 * wallis_recursive_product(1, n)
  end

  # Базов случай: стигнали сме до n-тия член
  defp wallis_recursive_product(k, n) when k > n do
    1.0
  end

  # Рекурсивен случай: term(k) * product(k+1)
  defp wallis_recursive_product(k, n) do
    numerator = 4.0 * k * k
    denominator = 4.0 * k * k - 1.0
    term = numerator / denominator

    term * wallis_recursive_product(k + 1, n)
  end

  @doc """
  Линейно-итеративна реализация (циклична чрез опашкова рекурсия).
  """
  def wallis_iterative(n) when n > 0 do
    2.0 * wallis_iterative_loop(1, n, 1.0)
  end

  # Опашкова рекурсия с акумулатор
  defp wallis_iterative_loop(k, n, acc) when k > n do
    acc
  end

  defp wallis_iterative_loop(k, n, acc) do
    numerator = 4.0 * k * k
    denominator = 4.0 * k * k - 1.0
    term = numerator / denominator
    wallis_iterative_loop(k + 1, n, acc * term)
  end
end
