defmodule FormIO.FieldDescriptor do
  @type t :: %FormIO.FieldDescriptor{ name: String.t, single: boolean()}
  defstruct name: "", single: true
end

