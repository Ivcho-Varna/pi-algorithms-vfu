defmodule PiNilakantha do
  @moduledoc """
  Приближение на π чрез серията на Nilakantha.
  """

  @doc """
  Рекурсивна реализация (не-опашкова).

  Формула на Nilakantha:
  π = 3 + 4/(2*3*4) - 4/(4*5*6) + 4/(6*7*8) - 4/(8*9*10) + ...
  π = 3 + ∑[k=1 до n] (-1)^(k+1) * 4 / ((2k)(2k+1)(2k+2))
  """
  def nilakantha_recursive(n) when n > 0 do
    3.0 + nilakantha_recursive_sum(1, n)
  end

  # Базов случай: стигнали сме до n-тия член
  defp nilakantha_recursive_sum(k, n) when k > n do
    0.0
  end

  # Рекурсивен случай: term(k) + sum(k+1)
  defp nilakantha_recursive_sum(k, n) do
    denominator = (2.0 * k) * (2.0 * k + 1.0) * (2.0 * k + 2.0)
    sign = if rem(k, 2) == 1, do: 1.0, else: -1.0
    term = sign * 4.0 / denominator

    term + nilakantha_recursive_sum(k + 1, n)
  end

  @doc """
  Линейно-итеративна реализация (циклична чрез опашкова рекурсия).
  """
  def nilakantha_iterative(n) when n > 0 do
    3.0 + nilakantha_iterative_loop(1, n, 0.0)
  end

  # Опашкова рекурсия с акумулатор
  defp nilakantha_iterative_loop(k, n, acc) when k > n do
    acc
  end

  defp nilakantha_iterative_loop(k, n, acc) do
    denominator = (2.0 * k) * (2.0 * k + 1.0) * (2.0 * k + 2.0)
    sign = if rem(k, 2) == 1, do: 1.0, else: -1.0
    term = sign * 4.0 / denominator
    nilakantha_iterative_loop(k + 1, n, acc + term)
  end
end
