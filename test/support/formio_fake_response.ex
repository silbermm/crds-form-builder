defmodule FormIOFakeResponses do
  #def get(fn) when is_function(fn) do
  #end
  def get("/good/response") do
    {:ok, %HTTPoison.Response{status_code: 200, body: "{\"_id\":\"234234\"}"}}
  end
  def get(url) do
    {:error, %HTTPoison.Error{reason: "no url match"}}
  end

  def fake_nested_components() do
    [
      %{"components" => [
          %{"columns" => [
            %{"components" => [
              %{"key" => "firstname", "properties" => 
                %{"data_field" => "First_Name", "data_table" => "Contacts"}
              },
              %{"key" => "lastname", "properties" => 
                %{"data_field" => "Last_Name", "data_table" => "Contacts"}
              }]},
            %{"components" => [
                %{"key" => "dateOfBirth", "properties" => 
                  %{"data_field" => "Birth_Date", "data_table" => "Contacts"}
                },
                %{"key" => "middlename", "properties" => 
                  %{"data_field" => "Middle_Name", "data_table" => "Contacts"}
                }]}
          ]},
          %{"key" => "maidenname", "properties" => 
            %{"data_field" => "MaidenName", "data_table" => "Contacts"}
          },
          %{"key" => "height", "properties" => 
             %{"data_field" => "Height", "data_table" => "Contacts"}
          }
      ]}
    ]
  end

  def fake_flattened_components() do
    [
      %{"key" => "firstname", "properties" => 
        %{"data_field" => "First_Name", "data_table" => "Contacts"}
      },
      %{"key" => "lastname", "properties" => 
        %{"data_field" => "Last_Name", "data_table" => "Contacts"}
      },
      %{"key" => "dateOfBirth", "properties" => 
        %{"data_field" => "Birth_Date", "data_table" => "Contacts"}
      },
      %{"key" => "middlename", "properties" => 
        %{"data_field" => "Middle_Name", "data_table" => "Contacts"}
      },
      %{"key" => "maidenname", "properties" => 
        %{"data_field" => "MaidenName", "data_table" => "Contacts"}
      },
      %{"key" => "height", "properties" => 
        %{"data_field" => "Height", "data_table" => "Contacts"}
      }
    ]
    
  end
end
