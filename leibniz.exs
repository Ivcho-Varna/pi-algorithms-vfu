defmodule PiLeibniz do
  @moduledoc """
  Приближение на π чрез реда на Лайбниц.
  """

  @doc """
  Рекурсивна реализация (не-опашкова).
  """
  def leibniz_recursive(n) when n > 0 do
    4.0 * leibniz_recursive_sum(0, n)
  end

  # Базов случай: стигнали сме до n-тия член (при k == n няма повече да добавяме).
  defp leibniz_recursive_sum(k, n) when k == n do
    0.0
  end

  # Рекурсивен случай: term(k) + sum(k+1)
  defp leibniz_recursive_sum(k, n) do
    sign = if rem(k, 2) == 0, do: 1.0, else: -1.0
    term = sign / (2 * k + 1)

    term + leibniz_recursive_sum(k + 1, n)
  end

  @doc """
  Линейно-итеративна реализация (циклична чрез опашкова рекурсия).
  """
  def leibniz_iterative(n) when n > 0 do
    4.0 * leibniz_iterative_loop(0, n, 0.0)
  end

  # Опашкова рекурсия с акумулатор
  defp leibniz_iterative_loop(k, n, acc) when k == n do
    acc
  end

  defp leibniz_iterative_loop(k, n, acc) do
    sign = if rem(k, 2) == 0, do: 1.0, else: -1.0
    term = sign / (2 * k + 1)
    leibniz_iterative_loop(k + 1, n, acc + term)
  end
end
