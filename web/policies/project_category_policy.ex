defmodule CodeCorps.ProjectCategoryPolicy do
  import Ecto.Query
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.ProjectCategory
  alias CodeCorps.User
  alias CodeCorps.Repo

  # TODO: Need to figure out how to pass in params. We need to know
  # if user is at least admin in organization, before they can assign
  # a category to a project. Same goes for delete
  def create?(%User{admin: true} = _user), do: true
  def create?(%User{} = _user), do: false
  def create?(%User{} = user, %ProjectCategory{} = project_category), do: user |> is_admin_or_higher(project_category)

  def delete?(%User{admin: true} = _user), do: true
  def delete?(%User{} = _user), do: false
  def delete?(%User{} = user, %ProjectCategory{} = project_category), do: user |> is_admin_or_higher(project_category)

  defp is_admin_or_higher(%User{} = user, %ProjectCategory{} = project_category) do
    project = Project |> Repo.get(project_category.project_id)

    membership =
      OrganizationMembership
      |> where([m], m.member_id == ^user.id and m.organization_id == ^project.organization_id)
      |> Repo.one

    membership |> is_admin_or_higher
  end

  defp is_admin_or_higher(nil), do: false
  defp is_admin_or_higher(%OrganizationMembership{} = membership), do: membership.role in ["admin", "owner"]
end
