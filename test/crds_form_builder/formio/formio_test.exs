defmodule CrdsFormBuilder.FormIOTest do
  use ExUnit.Case, async: true
  import Mock

  doctest FormIO

  alias FormIO.FieldDescriptor
  @data_adaptor Application.get_env(:formio, :adapator, FormIO.MinistryPlatform.Adaptor)

  describe "extract_data_fields" do
    test "one field with data properties" do
      component = [%{"properties" => 
        %{"data_field" => "First_Name", "data_table" => "Contacts"}
      }]
      result = FormIO.extract_data_fields(component)
      assert result == %{"Contacts" => [%FieldDescriptor{name: "First_Name", single: true}]}
    end

    test "multiple fields with different data properties" do
      component = [%{"properties" => 
        %{"data_field" => "First_Name", "data_table" => "Contacts"}
      }, %{"properties" => 
        %{"data_field" => "Household_Name", "data_table" => "Household"}
      }]
      result = FormIO.extract_data_fields(component)
      assert result == %{"Contacts" => [%FieldDescriptor{name: "First_Name", single: true}], "Household" => [%FieldDescriptor{name: "Household_Name", single: true}]}
    end

    test "multiple fields with same table" do
      component = [%{"properties" => 
        %{"data_field" => "First_Name", "data_table" => "Contacts"}
      }, %{"properties" => 
        %{"data_field" => "Last_Name", "data_table" => "Contacts"}
      }]
      result = FormIO.extract_data_fields(component)
      assert result == %{"Contacts" => [%FieldDescriptor{name: "First_Name", single: true}, %FieldDescriptor{name: "Last_Name", single: true}]}
    end
  end

  describe "form_exists" do
    test "form does exist at path" do
      with_mock HTTPoison, [get: fn(url) -> FormIOFakeResponses.get(url) end] do
        form_response = FormIO.form_exists("", "/good/response")
        assert {:ok, _} = form_response
        assert called HTTPoison.get("/good/response")
      end
    end

    test "form does not exist at path" do
      with_mock HTTPoison, [get: fn(url) -> FormIOFakeResponses.get(url) end] do
        form_response = FormIO.form_exists("", "/bad/response")
        assert {:error, _} = form_response
        assert called HTTPoison.get("/bad/response")
      end
    end
  end

  describe "flatten_components" do
    setup do
      pre_data = FormIOFakeResponses.fake_nested_components()
      post_data = FormIOFakeResponses.fake_flattened_components()
      {:ok, pre_data: pre_data, post_data: post_data}
    end

    test "flattens correctly", %{pre_data: pre_data, post_data: post_data} do
      flattened = FormIO.flatten_components(pre_data)
      assert flattened == post_data
    end
  end

  describe "fetch_data_to_prepopulate_form" do
    setup do
      pre_data = FormIOFakeResponses.fake_nested_components()
      post_data = FormIOFakeResponses.fake_flattened_components()
      {:ok, pre_data: pre_data, post_data: post_data}
    end

    test "gets data and builds submission map", %{pre_data: pre_data, post_data: post_data} do
      with_mock @data_adaptor, [fetch_field_data: fn(_data) -> FormIOFakeResponses.fake_field_data() ] do
        task = FormIO.fetch_data_to_prepopulate_form(pre_data)
      end
    end
  end
end
