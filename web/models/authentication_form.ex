defmodule OmniChat.AuthenticationForm do
  defstruct authentication_code: nil
end

defimpl Phoenix.HTML.FormData, for: OmniChat.AuthenticationForm do
  def to_form(auth_form, options) do
    %Phoenix.HTML.Form{
      source: auth_form,
      impl: __MODULE__,
      id: options[:as],
      name: options[:as]
    }
  end

  def to_form(_, _, _, _) do
    %Phoenix.HTML.Form{}
  end

  def input_type(_changeset, _field) do
    :text_input
  end

  def input_validations(_changeset, _field) do
    [required: false]
  end
end
