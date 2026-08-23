class RenameHomeProfilesToPersonal < ActiveRecord::Migration[8.1]
  def up
    rename_default("Home", "Personal")
    rename_default("Início", "Pessoal")
  end

  def down
    rename_default("Personal", "Home")
    rename_default("Pessoal", "Início")
  end

  private
    def rename_default(from, to)
      Profile.where(name: from, position: 0).find_each do |profile|
        taken = profile.user.profiles.where("LOWER(name) = ?", to.downcase).exists?
        next if taken

        profile.update_column(:name, to)
      end
    end
end
