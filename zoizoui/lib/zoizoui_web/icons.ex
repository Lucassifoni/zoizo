defmodule ZoizouiWeb.Icons do
  use Phoenix.Component

  attr :icon, :string, required: true
  def zicon(%{icon: i} = assigns) when i in ~w(CROIX
  FLECHE-BAS
  FLECHE-DROITE
  FLECHE-GAUCHE
  FLECHE-HAUT
  FOCUS-AF
  FOCUS-MOINS
  FOCUS-PLUS
  PHOTO
  PHOTOTHEQUE
  PRISES
  REGLAGES
  ) do
    ~H"""
    <img class="w-10 h-auto max-w-[60px]" src={"/images/icons/#{@icon}.svg"}/>
    """
  end
end
