defmodule Telnyx.ServiceCase do
  @moduledoc """
  This module defines the test case to be used by
  service tests.

  If the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Telnyx.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Telnyx.ServiceCase
      import Telnyx.TestHelpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Telnyx.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Telnyx.Repo, {:shared, self()})
    end

    :ok
  end
end
