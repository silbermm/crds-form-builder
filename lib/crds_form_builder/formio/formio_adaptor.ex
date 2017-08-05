defmodule FormIO.Adaptor do
  alias FormIO.FieldDescriptor
  @type data_map :: %{ table :: String.t => [field_descriptor :: FieldDescriptor.t] }
  @callback fetch_field_data(data_map) :: any()
end
