defmodule Issues.TableFormatter do
  import Enum, only: [each: 2, map: 2, map_join: 3, max: 1]

  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
         column_widths = widths_of(data_by_columns),
         format = format_for(column_widths) do
      puts_one_line_in_columns(headers, format)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, format)
    end
  end

  @doc """
  Given a list of rows, where each row contains a keyed list
  of columns, return a list containing lists of the data in
  each column. The `headers` parameter contains the
  list of columns to extract

  ## Example

    iex> list = [Enum.into([{"a", "1"}, {"b", "2"}, {"c", "3"}], %{}),
    ...>         Enum.into([{"a", "4"}, {"b", "5"}, {"c", "6"}], %{})]
    iex> Issues.TableFormatter.split_into_columns(list, [ "a", "b", "c" ])
    [ ["1", "4"], ["2", "5"], ["3", "6"] ]
  """

  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows do
        printable(row[header])
      end
    end
  end

  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  def widths_of(columns) do
    for column <- columns do
      column |> map(&String.length/1) |> max
    end
  end

  @doc """
  Return a format string that hard-codes the widths of a set of columns.
  We put `" | "` between each column.

  ## Example
  iex> widths = [5,6,99]
  iex> Issues.TableFormatter.format_for(widths)
  "~-5s | ~-6s | ~-99s~n"
  """
  def format_for(column_widths) do
    map_join(column_widths, " | ", &"~-#{&1}s") <> "~n"
  end

  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> Enum.zip()
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end

  def puts_one_line_in_columns(fields, format) do
    :io.format(format, fields)
  end
end
