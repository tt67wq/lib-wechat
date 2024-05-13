defmodule LibWechatTest do
  @moduledoc false
  use ExUnit.Case

  alias LibWechat.Debug
  alias LibWechat.Test.App

  setup do
    cfg = [
      appid: System.get_env("TEST_APP_ID"),
      secret: System.get_env("TEST_APP_SECRET")
    ]

    Application.put_env(:app, LibWechat.Test.App, cfg)

    start_supervised!(LibWechat.Test.App)

    :ok
  end

  test "get_access_token" do
    assert {:ok, res} = App.get_access_token()
    Debug.debug(res)
  end

  test "get_unlimited_wxacode" do
    {:ok, %{"access_token" => token}} = App.get_access_token()

    payload = %{
      "scene" => "foo=bar",
      "page" => "pages/hope/index",
      "width" => 430,
      "auto_color" => false,
      "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
      "is_hyaline" => false
    }

    assert {:ok, res} = App.get_unlimited_wxacode(token, payload)
    Debug.debug(res)
  end

  test "get_urllink" do
    {:ok, %{"access_token" => token}} = App.get_access_token()

    payload = %{
      "path" => "pages/hope/index",
      "query" => "foo=bar",
      "is_expire" => false,
      "expire_type" => 0,
      "expire_time" => 0
    }

    assert {:ok, res} = App.get_urllink(token, payload)
    Debug.debug(res)
  end

  test "generate_scheme" do
    {:ok, %{"access_token" => token}} = App.get_access_token()

    payload = %{
      "jump_wxa" => %{
        "path" => "pages/hope/index",
        "query" => "foo=bar"
      },
      "is_expire" => false,
      "expire_type" => 0,
      "expire_time" => 0
    }

    assert {:ok, res} = App.generate_scheme(token, payload)
    Debug.debug(res)
  end

  test "subscribe_send" do
    {:ok, %{"access_token" => token}} = App.get_access_token()

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

    assert {:ok, res} = App.subscribe_send(token, payload)
    Debug.debug(res)
  end

  test "uniform_send" do
    {:ok, %{"access_token" => token}} = App.get_access_token()

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

    assert {:ok, res} = App.uniform_send(token, payload)
    Debug.debug(res)
  end

  @tag exec: true
  test "msg_sec_check" do
    {:ok, %{"access_token" => token}} = App.get_access_token()

    assert {:ok, res} =
             App.msg_sec_check(token, %{
               "content" => "hello",
               "openid" => "ohNY75Jw8MlsKuu4cFBbjmK4ZP_w",
               "version" => 2,
               "scene" => 1
             })

    Debug.debug(res)
  end
end
