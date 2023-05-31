defmodule LibWechatTest do
  use ExUnit.Case

  setup do
    test_data = File.read!("tmp/test.json") |> Jason.decode!()

    wechat =
      LibWechat.new(
        appid: test_data["appid"],
        secret: test_data["secret"]
      )

    start_supervised!({LibWechat, wechat: wechat})

    {:ok, %{"access_token" => token}} = LibWechat.get_access_token(wechat)

    {:ok, %{wechat: wechat, token: token}}
  end

  test "get_unlimited_wxacode", %{wechat: wechat, token: token} do
    payload = %{
      "scene" => "foo=bar",
      "page" => "pages/hope/index",
      "width" => 430,
      "auto_color" => false,
      "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
      "is_hyaline" => false
    }

    assert {:ok, _} = LibWechat.get_unlimited_wxacode(wechat, token, payload)
  end

  test "get_urllink", %{wechat: wechat, token: token} do
    payload = %{
      "path" => "pages/hope/index",
      "query" => "foo=bar"
    }

    assert {:ok, _} = LibWechat.get_urllink(wechat, token, payload)
  end

  test "generate_scheme", %{wechat: wechat, token: token} do
    payload = %{
      "jump_wxa" => %{
        "path" => "pages/hope/index",
        "query" => "foo=bar"
      }
    }

    assert {:ok, _} = LibWechat.generate_scheme(wechat, token, payload)
  end

  test "subscribe_send", %{wechat: wechat, token: token} do
    payload = %{
      "touser" => "ohNY75Jw8MlsKuu4cFBbjmK4ZP_w",
      "template_id" => "c7R2mJAK3gzd1t7sm01DEiaOoSuIoATXt9h0syeZ300",
      "page" => "pages/hope/index",
      "data" => %{
        "name3" => %{"value" => "hello"},
        "time7" => %{"value" => "2020-01-01"},
        "time8" => %{"value" => "2020-01-01"},
        "thing9" => %{"value" => "hello"}
      }
    }

    assert {:ok, _} = LibWechat.subscribe_send(wechat, token, payload)
  end

  test "uniform_send", %{wechat: wechat, token: token} do
    payload = %{
      "touser" => "ohNY75Jw8MlsKuu4cFBbjmK4ZP_w",
      "mp_template_msg" => %{
        "appid" => "wx616179bd912752f2",
        "template_id" => "GBliwmqr52UXof5aJqo0mxovSZBu7A1RdAZJ7x252NI",
        "url" => "",
        "miniprogram" => %{
          "appid" => "wxefd6b215fca0cacd",
          "path" => "index"
        },
        "data" => %{
          "first" => %{
            "value" => "您好，Hope提醒您"
          },
          "keyword1" => %{
            "value" => "nick"
          },
          "keyword2" => %{
            "value" => "2023-05-28"
          },
          "keyword3" => %{
            "value" => "进行心理康复训练"
          },
          "remark" => %{
            "value" => "不要忘了哦"
          }
        }
      }
    }

    assert {:ok, _} = LibWechat.uniform_send(wechat, token, payload)
  end
end
