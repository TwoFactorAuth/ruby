class CreateFidoLoginRegistrations < ActiveRecord::Migration
  def change
    create_table :fido_login_registrations do |t|
      t.references :login, polymorphic: true, null: false, index: true
      t.binary :key_handle,  null: false, limit: 65 # Defined in fido pec
      t.binary :public_key,  null: false, limit: 10.kilobytes
      t.binary :certificate, null: false, limit: 1.megabyte, default: ""
      t.integer :counter,    null: false, limit: 5, default: 0 # limit in bytes; no easy way to get a 32b *unsigned*
      t.timestamp :last_authenticated_at, null: false
      t.timestamps
    end
    add_index :fido_login_registrations, :key_handle
    add_index :fido_login_registrations, :last_authenticated_at
  end
end
