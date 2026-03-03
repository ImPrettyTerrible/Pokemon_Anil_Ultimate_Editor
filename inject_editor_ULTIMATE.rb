#!/usr/bin/env ruby
# inject_editor_ULTIMATE.rb
# Inyecta editor ULTIMATE multifunción

# © Todos los derechos pertenecen a sus respectivos dueños. (Eric Lostie Pokémon Añil https://lostiefangames.blogspot.com/p/pokemon-anil.html)
# Pokémon es propiedad de The Pokémon Company, Nintendo y Game Freak.
# Este script es una herramienta fanmade sin fines de lucro.

# Uso: En Windows introducir este archivo en la misma carpeta que "Game.exe" y abrir un terminal/cmd ahí mismo (click derecho en la carpeta)
# Una vez en la terminal introducir la siguiente línea: 
# ruby inject_editor_ULTIMATE.rb (O el nombre que tenga el archivo en caso de ser distinto a este) ""Disco":\"Usuarios"\"Tu Usuario"\"Lugar de la carpeta"\ANIL V3.52\Pokemon Anil V3.52\Data\Scripts.rxdata"
# IMPORTANTE : Sustituir los entrecomillados por la dirección correcta según la ruta o nombres de directorios de tu dispositivo.
# IMPORTANTE v2 : Si tras introducir el comando en terminal no aparece la verificación en terminal o algun error o pese al mensaje positivo
# el juego no parece verse afectado por el script o el F9 (botón por defecto para abrir menú) no hace nada, cerrar el juego y repetir el comando en terminal.

# ES FÁCIL SABER SI EL SCRIPT FUE APLICADO CORRECTAMENTE. SI AL ABRIR EL JUEGO ÉSTE TOMA UNOS SEGUNDOS MÁS Y EN PANTALLA APARECE UN CUADRO DE TEXTO INDICANDO QUE EL SERVICIO SE ESTA INICIALIZANDO, ENTONCES EL SCRIPT FUE CARGADO ADECUADAMENTE.

require 'zlib'

if ARGV.empty?
  puts "=" * 70
  puts "INYECTOR ULTIMATE EDITOR"
  puts "=" * 70
  puts ""
  puts "Uso:"
  puts '  ruby inject_editor_ULTIMATE.rb "ruta\\a\\Data\\Scripts.rxdata"'
  puts ""
  puts "Ejemplo:"
  puts '  ruby inject_editor_ULTIMATE.rb "C:\\Juego\\Data\\Scripts.rxdata"'
  puts ""
  exit 0
end

scripts_path = ARGV[0]

unless File.exist?(scripts_path)
  abort "❌ No se encuentra: #{scripts_path}"
end

puts "=" * 70
puts "INYECTOR ULTIMATE EDITOR"
puts "=" * 70
puts "📂 Scripts: #{scripts_path}"
puts ""

# Crear backup
backup_path = scripts_path + ".backup"
unless File.exist?(backup_path)
  require 'fileutils'
  FileUtils.cp(scripts_path, backup_path)
  puts "📋 Backup creado: #{backup_path}"
end

# Cargar scripts
puts "⚙️  Cargando scripts del juego..."
scripts = Marshal.load(File.binread(scripts_path))
puts "✅ #{scripts.length} scripts cargados"

# Código ULTIMATE Editor
ultimate_code = <<'RUBY_CODE'
p "Editor Ultimate cargando..."

# Función de seguridad para verificar compatibilidad
def pbEditorSafeCheck
  return false if !$Trainer
  return false if !$Trainer.party
  return false if $Trainer.party.empty?
  
  # Verificar que todos los Pokémon en el party sean válidos
  $Trainer.party.each do |pkmn|
    return false if !pkmn
    return false if !pkmn.respond_to?(:species)
  end
  
  return true
end

def pbPerfectIVs
  return if !pbEditorSafeCheck
  p "IVs perfectos aplicados"
  $Trainer.party.each do |pkmn|
    next if !pkmn
    6.times { |i| pkmn.iv[i] = 31 }
    pkmn.calcStats rescue nil
  end
  Kernel.pbMessage("IVs perfectos aplicados a todo el party") rescue nil
end

def pbShowIVs
  return if !pbEditorSafeCheck
  msg = "IVs del Party:"
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn
    msg += "\n#{i+1}. #{pkmn.name}: #{pkmn.iv.join(',')}"
  end
  Kernel.pbMessage(msg) rescue nil
end

def pbShowEVs
  return if !pbEditorSafeCheck
  msg = "EVs del Party:"
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn
    msg += "\n#{i+1}. #{pkmn.name}: "
    msg += "HP#{pkmn.ev[0]} "
    msg += "Atk#{pkmn.ev[1]} "
    msg += "Def#{pkmn.ev[2]} "
    msg += "Spe#{pkmn.ev[3]} "
    msg += "SpA#{pkmn.ev[4]} "
    msg += "SpD#{pkmn.ev[5]}"
  end
  Kernel.pbMessage(msg) rescue nil
end

def pbSelectPokemon
  return nil if !pbEditorSafeCheck
  
  commands = []
  $Trainer.party.each_with_index do |pkmn, i|
    if pkmn
      commands.push("#{i+1}. #{pkmn.name} Nv.#{pkmn.level}")
    else
      commands.push("#{i+1}. --- Vacío ---")
    end
  end
  commands.push("Cancelar")
  
  cmd = Kernel.pbShowCommands(nil, commands, -1) rescue nil
  return nil if cmd.nil? || cmd < 0 || cmd >= $Trainer.party.length
  return cmd
end

def pbEditIVsManual(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Editando IVs manualmente de #{pkmn.name}"
  
  stats = ["HP", "Ataque", "Defensa", "Velocidad", "Ataque Especial", "Defensa Especial"]
  
  loop do
    commands = []
    stats.each_with_index do |stat, i|
      commands.push("#{stat}: #{pkmn.iv[i]}")
    end
    commands.push("IVs Perfectos", "Volver")
    
    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 7
    break if cmd == 7 || cmd.nil?
    
    if cmd >= 0 && cmd < 6
      params = ChooseNumberParams.new
      params.setRange(0, 31)
      params.setDefaultValue(pkmn.iv[cmd])
      params.setCancelValue(-1)
      new_iv = Kernel.pbMessageChooseNumber("Nuevo valor de IV para #{stats[cmd]} (0-31):", params) rescue -1
      
      if new_iv >= 0
        pkmn.iv[cmd] = new_iv
        p "IV de #{stats[cmd]} cambiado a #{new_iv}"
        Kernel.pbMessage("#{stats[cmd]} cambiado a #{new_iv}") rescue nil
        pkmn.calcStats rescue nil
      end
    elsif cmd == 6
      6.times { |i| pkmn.iv[i] = 31 }
      pkmn.calcStats rescue nil
      Kernel.pbMessage("IVs perfectos aplicados a #{pkmn.name}") rescue nil
      p "IVs perfectos aplicados"
    end
  end
end

def pbEditEVsManual(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Editando EVs manualmente de #{pkmn.name}"
  
  stats = ["HP", "Ataque", "Defensa", "Velocidad", "Ataque Especial", "Defensa Especial"]
  
  loop do
    current_total = pkmn.ev[0] + pkmn.ev[1] + pkmn.ev[2] + pkmn.ev[3] + pkmn.ev[4] + pkmn.ev[5]
    commands = []
    
    commands.push("HP: #{pkmn.ev[0]}")
    commands.push("Ataque: #{pkmn.ev[1]}")
    commands.push("Defensa: #{pkmn.ev[2]}")
    commands.push("Velocidad: #{pkmn.ev[3]}")
    commands.push("Ataque Especial: #{pkmn.ev[4]}")
    commands.push("Defensa Especial: #{pkmn.ev[5]}")
    
    commands.push("Resetear EVs", "Volver")
    
    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 7
    break if cmd == 7 || cmd.nil?
    
    if cmd >= 0 && cmd < 6
      params = ChooseNumberParams.new
      params.setRange(0, 252)
      
      current_ev = pkmn.ev[cmd]
      
      params.setDefaultValue(current_ev)
      params.setCancelValue(-1)
      new_ev = Kernel.pbMessageChooseNumber("Nuevo EV para #{stats[cmd]} (0-252):", params) rescue -1
      
      if new_ev >= 0
        current_ev_value = pkmn.ev[cmd]
        new_total = current_total - current_ev_value + new_ev
        
        if new_total <= 510
          pkmn.ev[cmd] = new_ev
          
          p "EV de #{stats[cmd]} cambiado a #{new_ev}"
          Kernel.pbMessage("#{stats[cmd]} cambiado a #{new_ev} (Total: #{new_total}/510)") rescue nil
          pkmn.calcStats rescue nil
        else
          Kernel.pbMessage("¡Demasiados EVs! Máximo 510 (actual: #{new_total})") rescue nil
        end
      end
    elsif cmd == 6
      6.times { |i| pkmn.ev[i] = 0 }
      
      pkmn.calcStats rescue nil
      Kernel.pbMessage("EVs de #{pkmn.name} reseteados a 0") rescue nil
      p "EVs reseteados"
    end
  end
end

def pbEditNature(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Editando naturaleza de #{pkmn.name}"
  
  natures = [
    "Adamant (+Atk -SpA)",
    "Modest (+SpA -Atk)", 
    "Jolly (+Spe -SpA)",
    "Timid (+Spe -Atk)",
    "Bold (+Def -Atk)",
    "Impish (+Def -SpA)",
    "Calm (+SpD -Atk)",
    "Careful (+SpD -SpA)",
    "Brave (+Atk -Spe)",
    "Quiet (+SpA -Spe)",
    "Relaxed (+Def -Spe)",
    "Sassy (+SpD -Spe)",
    "Lonely (+Atk -Def)",
    "Mild (+SpA -Def)",
    "Rash (+SpA -SpD)",
    "Gentle (+SpD -Def)", 
    "Hasty (+Spe -Def)",
    "Naive (+Spe -SpD)",
    "Naughty (+Atk -SpD)",
    "Lax (+Def -SpD)",
    "Serious (Neutral)",
    "Cancelar"
  ]
  
  nature_ids = [3, 15, 13, 10, 5, 8, 20, 23, 2, 17, 7, 22, 1, 16, 19, 21, 11, 14, 4, 9, 0]
  nature_names = ["Adamant","Modest","Jolly","Timid","Bold","Impish","Calm","Careful","Brave","Quiet","Relaxed","Sassy","Lonely","Mild","Rash","Gentle","Hasty","Naive","Naughty","Lax","Serious"]
  
  current_nature = PBNatures.getName(pkmn.nature) rescue "Naturaleza #{pkmn.nature}"
  
  cmd = Kernel.pbShowCommands(nil, natures, -1) rescue 21
  return if cmd.nil? || cmd == 21
  
  if cmd >= 0 && cmd < 21
    if pkmn.respond_to?(:setNature)
      pkmn.setNature(nature_ids[cmd])
    else
      pkmn.nature = nature_ids[cmd]
    end
    pkmn.calcStats rescue nil
    Kernel.pbMessage("Naturaleza cambiada: #{current_nature} → #{nature_names[cmd]}") rescue nil
    p "Naturaleza cambiada a #{nature_names[cmd]}"
  end
end

def pbEditAbility(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Editando habilidad de #{pkmn.name}"
  
  abilities = pkmn.getAbilityList rescue []
  return if !abilities || abilities.empty?
  
  commands = []
  ability_ids = []
  
  abilities.each do |ability_data|
    ability_id = ability_data[0]
    ability_name = PBAbilities.getName(ability_id) rescue "Habilidad #{ability_id}"
    is_hidden = (ability_data[1] == 2)
    
    if is_hidden
      commands.push("#{ability_name} (Oculta)")
    else
      commands.push(ability_name)
    end
    ability_ids.push(ability_id)
  end
  
  commands.push("Cancelar")
  
  cmd = Kernel.pbShowCommands(nil, commands, -1) rescue commands.length - 1
  return if cmd.nil? || cmd < 0 || cmd >= ability_ids.length
  
  new_ability = ability_ids[cmd]
  old_ability_name = PBAbilities.getName(pkmn.ability) rescue "Habilidad #{pkmn.ability}"
  new_ability_name = PBAbilities.getName(new_ability) rescue "Habilidad #{new_ability}"
  
  p "Intentando cambiar habilidad de #{old_ability_name} a #{new_ability_name}"
  
  success = false
  method_used = "Ninguno"
  
  if !success && pkmn.respond_to?(:setAbility)
    begin
      pkmn.setAbility(new_ability)
      success = (pkmn.ability == new_ability)
      method_used = "setAbility" if success
      p "✅ Habilidad cambiada usando setAbility" if success
    rescue => e
      p "❌ Error con setAbility: #{e.message}"
    end
  end
  
  if !success && pkmn.instance_variable_defined?(:@ability)
    begin
      pkmn.instance_variable_set(:@ability, new_ability)
      success = (pkmn.ability == new_ability)
      method_used = "@ability" if success
      p "✅ Habilidad cambiada usando @ability" if success
    rescue => e
      p "❌ Error con @ability: #{e.message}"
    end
  end
  
  if !success && pkmn.respond_to?(:ability_index)
    begin
      ability_index = abilities.find_index { |a| a[0] == new_ability }
      if ability_index
        pkmn.ability_index = ability_index
        success = (pkmn.ability == new_ability)
        method_used = "ability_index" if success
        p "✅ Habilidad cambiada usando ability_index" if success
      end
    rescue => e
      p "❌ Error con ability_index: #{e.message}"
    end
  end
  
  if !success
    begin
      p "Intentando forzar habilidad oculta con flag..."
      
      if pkmn.respond_to?(:setAbility) && abilities[cmd][1] == 2
        if pkmn.respond_to?(:abilityflag)
          pkmn.abilityflag = 2
        end
        
        pkmn.setAbility(new_ability)
        success = (pkmn.ability == new_ability)
        method_used = "Forzar oculta" if success
        p "✅ Habilidad oculta forzada" if success
      end
    rescue => e
      p "❌ Error forzando habilidad oculta: #{e.message}"
    end
  end
  
  if !success
    begin
      p "Intentando recreación simple con habilidad forzada..."
      
      temp_iv = pkmn.iv.clone
      temp_ev = pkmn.ev.clone
      temp_level = pkmn.level
      temp_exp = pkmn.exp
      temp_moves = pkmn.moves.map { |m| m ? m.id : nil }
      temp_item = pkmn.item
      temp_pokerus = pkmn.pokerus rescue 0
      temp_ot = pkmn.ot rescue "Player"
      temp_otgender = pkmn.otgender rescue 0
      temp_id = pkmn.id rescue 12345
      temp_name = pkmn.name
      
      new_pkmn = PokeBattle_Pokemon.new(pkmn.species, temp_level)
      
      new_pkmn.iv = temp_iv
      new_pkmn.ev = temp_ev
      new_pkmn.exp = temp_exp
      new_pkmn.item = temp_item
      new_pkmn.ot = temp_ot
      new_pkmn.otgender = temp_otgender
      new_pkmn.id = temp_id
      new_pkmn.name = temp_name
      
      temp_moves.each_with_index do |move_id, i|
        if move_id && move_id > 0
          new_pkmn.moves[i] = PBMove.new(move_id)
        end
      end
      
      if new_pkmn.respond_to?(:setAbility)
        new_pkmn.setAbility(new_ability)
      end
      
      if new_pkmn.instance_variable_defined?(:@ability)
        new_pkmn.instance_variable_set(:@ability, new_ability)
      end
      
      if abilities[cmd][1] == 2
        if new_pkmn.respond_to?(:abilityflag=)
          new_pkmn.abilityflag = 2
        elsif new_pkmn.instance_variable_defined?(:@abilityflag)
          new_pkmn.instance_variable_set(:@abilityflag, 2)
        end
      end
      
      party_index = $Trainer.party.index(pkmn)
      if party_index
        $Trainer.party[party_index] = new_pkmn
        pkmn = new_pkmn
        success = (pkmn.ability == new_ability)
        method_used = "Recreación forzada" if success
        p "✅ Pokémon recreado con habilidad forzada" if success
      end
    rescue => e
      p "❌ Error en recreación forzada: #{e.message}"
    end
  end
  
  if !success && abilities[cmd][1] == 2
    begin
      p "Último método: cambio temporal de species..."
      
      temp_species = pkmn.species
      
      if pkmn.respond_to?(:species=)
        pkmn.species = 1
        pkmn.species = temp_species
        
        if pkmn.respond_to?(:setAbility)
          pkmn.setAbility(new_ability)
          success = (pkmn.ability == new_ability)
          method_used = "Reset species" if success
        end
      end
    rescue => e
      p "❌ Error con cambio de species: #{e.message}"
    end
  end
  
  final_ability = pkmn.ability
  final_ability_name = PBAbilities.getName(final_ability) rescue "Habilidad #{final_ability}"
  
  if success
    p "✅ Habilidad cambiada exitosamente a #{final_ability_name} (método: #{method_used})"
    Kernel.pbMessage("✅ Habilidad cambiada: #{old_ability_name} → #{final_ability_name}") rescue nil
    pkmn.calcStats rescue nil
    
    if abilities[cmd][1] == 2
      Kernel.pbMessage("¡Habilidad oculta activada! Es posible que necesites:\n• Guardar y recargar la partida\n• Entrar en combate para verificar") rescue nil
    end
  else
    p "❌ No se pudo cambiar la habilidad. Permanece: #{final_ability_name}"
    
    if abilities[cmd][1] == 2
      Kernel.pbMessage("❌ No se pudo asignar la habilidad oculta.\n\nPosibles causas:\n• El Pokémon no puede tener habilidad oculta\n• Restricciones específicas del juego\n• Intenta evolucionar el Pokémon primero") rescue nil
    else
      Kernel.pbMessage("❌ No se pudo cambiar la habilidad. Permanece: #{final_ability_name}") rescue nil
    end
  end
end

def pbEditGender(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Editando género de #{pkmn.name}"
  
  current_gender = pkmn.gender
  current_gender_str = case current_gender
  when 0 then "Macho"
  when 1 then "Hembra"
  else "Sin género"
  end
  
  commands = ["Macho", "Hembra", "Sin género", "Cancelar"]
  
  cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 3
  return if cmd.nil? || cmd == 3
  
  new_gender = case cmd
  when 0 then 0
  when 1 then 1
  when 2 then 2
  end
  
  if new_gender != current_gender
    if pkmn.respond_to?(:setGender)
      pkmn.setGender(new_gender)
    else
      pkmn.gender = new_gender
    end
    new_gender_str = commands[cmd]
    p "Género cambiado de #{current_gender_str} a #{new_gender_str}"
    Kernel.pbMessage("Género cambiado: #{current_gender_str} → #{new_gender_str}") rescue nil
  else
    Kernel.pbMessage("El Pokémon ya tiene el género #{current_gender_str}") rescue nil
  end
end

def pbEditHappiness(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Editando felicidad de #{pkmn.name}"
  
  current_happiness = pkmn.happiness rescue 0
  
  commands = [
    "Ver felicidad actual",
    "Cambiar felicidad manualmente",
    "Felicidad máxima (255)",
    "Felicidad para evolución (220)",
    "Felicidad mínima (0)",
    "Volver"
  ]
  
  cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 5
  return if cmd.nil? || cmd == 5
  
  case cmd
  when 0
    happiness_level = if current_happiness >= 220
      "Muy feliz (puede evolucionar)"
    elsif current_happiness >= 150
      "Feliz"
    elsif current_happiness >= 70
      "Normal"
    else
      "Infeliz"
    end
    Kernel.pbMessage("Felicidad de #{pkmn.name}: #{current_happiness}/255\nEstado: #{happiness_level}") rescue nil
  when 1
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(current_happiness)
    params.setCancelValue(-1)
    new_happiness = Kernel.pbMessageChooseNumber("Nueva felicidad para #{pkmn.name} (0-255):", params) rescue -1
    
    if new_happiness >= 0
      if pkmn.respond_to?(:happiness=)
        pkmn.happiness = new_happiness
      elsif pkmn.instance_variable_defined?(:@happiness)
        pkmn.instance_variable_set(:@happiness, new_happiness)
      end
      p "Felicidad cambiada de #{current_happiness} a #{new_happiness}"
      Kernel.pbMessage("Felicidad de #{pkmn.name} cambiada a #{new_happiness}") rescue nil
    end
  when 2
    if pkmn.respond_to?(:happiness=)
      pkmn.happiness = 255
    elsif pkmn.instance_variable_defined?(:@happiness)
      pkmn.instance_variable_set(:@happiness, 255)
    end
    p "Felicidad máxima (255) aplicada"
    Kernel.pbMessage("¡Felicidad máxima! #{pkmn.name} está súper feliz (255/255)") rescue nil
  when 3
    if pkmn.respond_to?(:happiness=)
      pkmn.happiness = 220
    elsif pkmn.instance_variable_defined?(:@happiness)
      pkmn.instance_variable_set(:@happiness, 220)
    end
    p "Felicidad para evolución (220) aplicada"
    Kernel.pbMessage("Felicidad establecida en 220\n#{pkmn.name} puede evolucionar por felicidad") rescue nil
  when 4
    if pkmn.respond_to?(:happiness=)
      pkmn.happiness = 0
    elsif pkmn.instance_variable_defined?(:@happiness)
      pkmn.instance_variable_set(:@happiness, 0)
    end
    p "Felicidad mínima (0) aplicada"
    Kernel.pbMessage("Felicidad reseteada a 0") rescue nil
  end
end

def pbShowPokemonInfo(pkmn)
  return if !pkmn || !pbEditorSafeCheck
  p "Mostrando info de #{pkmn.name}"
  
  gender_str = case pkmn.gender
  when 0 then "Macho"
  when 1 then "Hembra" 
  else "Sin género"
  end
  
  ability_name = PBAbilities.getName(pkmn.ability) rescue "Habilidad #{pkmn.ability}"
  nature_name = PBNatures.getName(pkmn.nature) rescue "Naturaleza #{pkmn.nature}"
  happiness = pkmn.happiness rescue 0
  
  info = "Información de #{pkmn.name}:\n"
  info += "Nivel: #{pkmn.level}\n"
  info += "Género: #{gender_str}\n"
  info += "Naturaleza: #{nature_name}\n"
  info += "Habilidad: #{ability_name}\n"
  info += "Felicidad: #{happiness}/255\n"
  info += "IVs: HP#{pkmn.iv[0]} Atk#{pkmn.iv[1]} Def#{pkmn.iv[2]} Spe#{pkmn.iv[3]} SpA#{pkmn.iv[4]} SpD#{pkmn.iv[5]}\n"
  info += "EVs: HP#{pkmn.ev[0]} Atk#{pkmn.ev[1]} Def#{pkmn.ev[2]} Spe#{pkmn.ev[3]} SpA#{pkmn.ev[4]} SpD#{pkmn.ev[5]}\n"
  info += "Total EVs: #{(pkmn.ev[0] + pkmn.ev[1] + pkmn.ev[2] + pkmn.ev[3] + pkmn.ev[4] + pkmn.ev[5])}/510"
  
  Kernel.pbMessage(info) rescue nil
end
# ─────────────────────────────────────────────────────────────────────────────
# CREAR POKÉMON — flujo guiado completo
# ─────────────────────────────────────────────────────────────────────────────

def pbSpeciesName(id)
  PBSpecies.getName(id) rescue "Pokémon ##{id}"
end

def pbMaxSpecies
  max = 0
  begin
    max = PBSpecies.maxValue
  rescue
    begin
      i = 1
      loop do
        name = PBSpecies.getName(i) rescue nil
        break if name.nil? || name.empty?
        max = i
        i += 1
        break if i > 2000
      end
    rescue
      max = 386
    end
  end
  max = 386 if max == 0
  return max
end

def pbValidSpecies?(id)
  return false if id <= 0
  name = PBSpecies.getName(id) rescue nil
  return false if name.nil? || name.empty?
  return true
end

def pbSelectSpeciesByNumber
  max = pbMaxSpecies
  params = ChooseNumberParams.new
  params.setRange(1, max)
  params.setDefaultValue(1)
  params.setCancelValue(-1)
  id = Kernel.pbMessageChooseNumber(
    "Introduce el número de Pokédex (1-#{max}):", params
  ) rescue -1
  return nil if id < 1
  unless pbValidSpecies?(id)
    Kernel.pbMessage("No existe ningún Pokémon con ese número.") rescue nil
    return nil
  end
  return id
end

def pbSelectSpeciesByList
  max  = pbMaxSpecies
  page = 0
  per  = 10

  loop do
    start_i = page * per + 1
    end_i   = [start_i + per - 1, max].min

    commands = []
    ids      = []
    (start_i..end_i).each do |i|
      name = pbSpeciesName(i)
      commands.push("##{i} #{name}")
      ids.push(i)
    end

    commands.push("« Anterior") if page > 0
    commands.push("Siguiente »") if end_i < max
    commands.push("Cancelar")

    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue (commands.length - 1)
    return nil if cmd.nil? || cmd < 0

    label = commands[cmd]

    if label == "Cancelar"
      return nil
    elsif label == "Siguiente »"
      page += 1
    elsif label == "« Anterior"
      page -= 1
    else
      return ids[cmd]
    end
  end
end

def pbSelectSpecies
  methods = ["Introducir número de Pokédex", "Buscar en lista", "Cancelar"]
  cmd = Kernel.pbShowCommands(nil, methods, -1) rescue 2
  return nil if cmd.nil? || cmd == 2
  case cmd
  when 0 then return pbSelectSpeciesByNumber
  when 1 then return pbSelectSpeciesByList
  end
  return nil
end

def pbChooseLevel
  params = ChooseNumberParams.new
  params.setRange(1, 100)
  params.setDefaultValue(50)
  params.setCancelValue(-1)
  lv = Kernel.pbMessageChooseNumber("Nivel del Pokémon (1-100):", params) rescue -1
  return lv >= 1 ? lv : nil
end

def pbChooseNatureForNew
  natures = [
    "Adamant (+Atk -SpA)",  "Modest (+SpA -Atk)",
    "Jolly (+Spe -SpA)",    "Timid (+Spe -Atk)",
    "Bold (+Def -Atk)",     "Impish (+Def -SpA)",
    "Calm (+SpD -Atk)",     "Careful (+SpD -SpA)",
    "Brave (+Atk -Spe)",    "Quiet (+SpA -Spe)",
    "Relaxed (+Def -Spe)",  "Sassy (+SpD -Spe)",
    "Lonely (+Atk -Def)",   "Mild (+SpA -Def)",
    "Rash (+SpA -SpD)",     "Gentle (+SpD -Def)",
    "Hasty (+Spe -Def)",    "Naive (+Spe -SpD)",
    "Naughty (+Atk -SpD)",  "Lax (+Def -SpD)",
    "Serious (Neutral)",    "Cancelar"
  ]
  nature_ids = [3,15,13,10,5,8,20,23,2,17,7,22,1,16,19,21,11,14,4,9,0]

  cmd = Kernel.pbShowCommands(nil, natures, -1) rescue 21
  return nil if cmd.nil? || cmd == 21
  return nature_ids[cmd]
end

def pbChooseIVsForNew
  stats = ["HP","Ataque","Defensa","Velocidad","Ataque Especial","Defensa Especial"]
  ivs   = [31,31,31,31,31,31]

  loop do
    commands = []
    stats.each_with_index { |s,i| commands.push("#{s}: #{ivs[i]}") }
    commands.push("Confirmar (IVs actuales)", "Todos perfectos (31)")

    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 7
    break if cmd.nil?

    if cmd < 6
      params = ChooseNumberParams.new
      params.setRange(0, 31)
      params.setDefaultValue(ivs[cmd])
      params.setCancelValue(-1)
      val = Kernel.pbMessageChooseNumber("IV de #{stats[cmd]} (0-31):", params) rescue -1
      ivs[cmd] = val if val >= 0
    elsif cmd == 6
      break
    elsif cmd == 7
      ivs = [31,31,31,31,31,31]
    end
  end

  return ivs
end

def pbChooseAbilityForNew(species, level)
  temp = PokeBattle_Pokemon.new(species, level) rescue nil
  return nil unless temp

  abilities = temp.getAbilityList rescue []
  return nil if abilities.nil? || abilities.empty?

  commands    = []
  ability_ids = []
  abilities.each do |adata|
    aid    = adata[0]
    aname  = PBAbilities.getName(aid) rescue "Habilidad #{aid}"
    hidden = (adata[1] == 2)
    commands.push(hidden ? "#{aname} (Oculta)" : aname)
    ability_ids.push(aid)
  end
  commands.push("Cancelar")

  cmd = Kernel.pbShowCommands(nil, commands, -1) rescue (commands.length - 1)
  return nil if cmd.nil? || cmd < 0 || cmd >= ability_ids.length
  return [ability_ids[cmd], abilities[cmd] ? abilities[cmd][1] : 0]
end

def pbChooseGenderForNew(species, level)
  temp = PokeBattle_Pokemon.new(species, level) rescue nil

  if temp
    genderrate = temp.genderRate rescue -1
    return 2 if genderrate == 255
    return 0 if genderrate == 0
    return 1 if genderrate == 254
  end

  commands = ["Macho","Hembra","Sin género","Cancelar"]
  cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 3
  return nil if cmd.nil? || cmd == 3
  return cmd
end

def pbChoosePokeball
  ball_names = [
    "Poké Ball",   "Super Ball",   "Ultra Ball",   "Master Ball",
    "Safari Ball", "Net Ball",     "Dive Ball",    "Nest Ball",
    "Repeat Ball", "Timer Ball",   "Luxury Ball",  "Premier Ball",
    "Dusk Ball",   "Heal Ball",    "Quick Ball",   "Cherish Ball",
    "Cancelar"
  ]
  ball_ids = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]

  cmd = Kernel.pbShowCommands(nil, ball_names, -1) rescue 16
  return nil if cmd.nil? || cmd == 16
  return ball_ids[cmd]
end

def pbCreatePokemon
  p "Abriendo asistente de creación de Pokémon"

  Kernel.pbMessage("── Paso 1/7: Especie ──\nElige el Pokémon que quieres crear.") rescue nil
  species = pbSelectSpecies
  return if species.nil?
  species_name = pbSpeciesName(species)

  Kernel.pbMessage("── Paso 2/7: Nivel ──\nElige el nivel de #{species_name}.") rescue nil
  level = pbChooseLevel
  return if level.nil?

  Kernel.pbMessage("── Paso 3/7: Naturaleza ──\nElige la naturaleza de #{species_name}.") rescue nil
  nature_id = pbChooseNatureForNew
  return if nature_id.nil?

  Kernel.pbMessage("── Paso 4/7: IVs ──\nPor defecto están a 31. Puedes ajustar stat a stat.") rescue nil
  ivs = pbChooseIVsForNew
  return if ivs.nil?

  Kernel.pbMessage("── Paso 5/7: Habilidad ──\nElige la habilidad de #{species_name}.") rescue nil
  ability_data     = pbChooseAbilityForNew(species, level)
  chosen_ability   = ability_data ? ability_data[0] : nil
  chosen_abilityfl = ability_data ? ability_data[1] : 0

  Kernel.pbMessage("── Paso 6/7: Género ──\nElige el género de #{species_name}.") rescue nil
  gender = pbChooseGenderForNew(species, level)
  return if gender.nil?

  Kernel.pbMessage("── Paso 7/7: Poké Ball ──\nElige la Poké Ball. Si cancelas se usará una Poké Ball normal.") rescue nil
  ball_id = pbChoosePokeball
  ball_id = 1 if ball_id.nil?

  nature_names = ["Hardy","Lonely","Brave","Adamant","Naughty","Bold","Docile","Relaxed",
                  "Impish","Lax","Timid","Hasty","Serious","Jolly","Naive","Modest",
                  "Mild","Quiet","Bashful","Rash","Calm","Gentle","Sassy","Careful","Quirky"]
  nature_str  = nature_names[nature_id] rescue "Naturaleza #{nature_id}"
  gender_str  = ["Macho","Hembra","Sin género"][gender] rescue "?"
  ability_str = chosen_ability ? (PBAbilities.getName(chosen_ability) rescue "Habilidad #{chosen_ability}") : "Default"
  iv_str      = "HP#{ivs[0]} Atk#{ivs[1]} Def#{ivs[2]} Spe#{ivs[3]} SpA#{ivs[4]} SpD#{ivs[5]}"

  summary  = "Resumen:\n#{species_name} Nv.#{level}\n"
  summary += "Naturaleza: #{nature_str} | Género: #{gender_str}\n"
  summary += "Habilidad: #{ability_str}\nIVs: #{iv_str}"

  confirm = Kernel.pbShowCommands(nil, ["✅ Confirmar y crear", "❌ Cancelar"], -1) rescue 1
  return if confirm.nil? || confirm == 1

  begin
    new_pkmn = PokeBattle_Pokemon.new(species, level)

    if new_pkmn.respond_to?(:setNature)
      new_pkmn.setNature(nature_id)
    else
      new_pkmn.nature = nature_id rescue nil
    end

    6.times { |i| new_pkmn.iv[i] = ivs[i] }

    if chosen_ability
      new_pkmn.setAbility(chosen_ability) rescue nil
      if new_pkmn.instance_variable_defined?(:@ability)
        new_pkmn.instance_variable_set(:@ability, chosen_ability) rescue nil
      end
      if chosen_abilityfl == 2
        if new_pkmn.respond_to?(:abilityflag=)
          new_pkmn.abilityflag = 2 rescue nil
        elsif new_pkmn.instance_variable_defined?(:@abilityflag)
          new_pkmn.instance_variable_set(:@abilityflag, 2) rescue nil
        end
      end
    end

    if new_pkmn.respond_to?(:setGender)
      new_pkmn.setGender(gender) rescue nil
    else
      new_pkmn.gender = gender rescue nil
    end

    if new_pkmn.respond_to?(:ballused=)
      new_pkmn.ballused = ball_id rescue nil
    elsif new_pkmn.instance_variable_defined?(:@ballused)
      new_pkmn.instance_variable_set(:@ballused, ball_id) rescue nil
    end

    new_pkmn.calcStats rescue nil

    party_full = ($Trainer.party.length >= 6)

    if !party_full
      $Trainer.party.push(new_pkmn)
      p "✅ #{species_name} añadido al party"
      Kernel.pbMessage("¡#{species_name} añadido a tu equipo!\n#{summary}") rescue nil
    else
      stored = false

      if defined?(pbStorePokemon) && !stored
        begin
          pbStorePokemon(new_pkmn)
          stored = true
        rescue => e
          p "pbStorePokemon falló: #{e.message}"
        end
      end

      if !stored && defined?($PokemonStorage) && $PokemonStorage
        begin
          box, slot = $PokemonStorage.pbStoreCaught(new_pkmn)
          stored = (box && slot)
        rescue => e
          p "PokemonStorage falló: #{e.message}"
        end
      end

      if stored
        Kernel.pbMessage("Tu equipo está completo.\n#{species_name} ha sido enviado al PC.") rescue nil
      else
        Kernel.pbMessage("❌ No se pudo añadir al PC.\nAsegúrate de tener espacio en el almacén.") rescue nil
      end
    end

  rescue => e
    p "❌ Error creando Pokémon: #{e.message}"
    Kernel.pbMessage("Error al crear el Pokémon:\n#{e.message}") rescue nil
  end
end

def pbUltimateEditor
  if !$Trainer
    p "❌ Editor: No hay datos de entrenador"
    Kernel.pbMessage("No se puede abrir el editor:\n• Partida no iniciada") rescue nil
    return
  end
  
  p "Editor Ultimate abierto"
  
 loop do
    commands = [
      "★ Crear Pokémon nuevo",
      "Editar IVs manualmente",
      "Editar EVs manualmente",
      "Cambiar Naturaleza",
      "Cambiar Habilidad",
      "Cambiar Género",
      "Editar Felicidad",
      "Ver Info Completa",
      "IVs perfectos a todos",
      "Ver IVs del party",
      "Ver EVs del party",
      "Cancelar"
    ]

    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 11
    break if cmd == 11 || cmd.nil?

    case cmd
    when 0
      pbCreatePokemon
    when 1
      slot = pbSelectPokemon
      pbEditIVsManual($Trainer.party[slot]) if slot
    when 2
      slot = pbSelectPokemon
      pbEditEVsManual($Trainer.party[slot]) if slot
    when 3
      slot = pbSelectPokemon
      pbEditNature($Trainer.party[slot]) if slot
    when 4
      slot = pbSelectPokemon
      pbEditAbility($Trainer.party[slot]) if slot
    when 5
      slot = pbSelectPokemon
      pbEditGender($Trainer.party[slot]) if slot
    when 6
      slot = pbSelectPokemon
      pbEditHappiness($Trainer.party[slot]) if slot
    when 7
      slot = pbSelectPokemon
      pbShowPokemonInfo($Trainer.party[slot]) if slot
    when 8
      pbPerfectIVs
    when 9
      pbShowIVs
    when 10
      pbShowEVs
    end
  end
end

if defined?(Scene_Map)
  class Scene_Map
    alias ultimate_editor_update update
    def update
      ultimate_editor_update
      if Input.trigger?(Input::F9)
        if $Trainer
          p "F9 presionado - Abriendo editor ULTIMATE"
          pbUltimateEditor
        else
          p "F9 presionado - No se puede abrir editor (partida no iniciada)"
          Kernel.pbMessage("Inicia una partida antes de usar el editor.") rescue nil
        end
      end
    end
  end
  p "Editor Ultimate instalado correctamente"
end

p "Editor Ultimate completamente cargado"
RUBY_CODE

# Comprimir código
compressed_code = Zlib::Deflate.deflate(ultimate_code)

# Buscar índice de Main
insert_index = scripts.length - 1
scripts.each_with_index do |script, i|
  next if !script || !script[1]
  if script[1] =~ /^Main$/i
    insert_index = i
    break
  end
end

# Eliminar editores anteriores por contenido, no por nombre
EDITOR_SIGNATURES = [
  "pbUltimateEditor",
  "pbEditorSafeCheck",
  "pbEditIVsManual",
  "pbCreatePokemon"
]

deleted_count = 0
scripts.delete_if do |s|
  next false if !s || !s[2] || s[2].empty?
  begin
    decompressed = Zlib::Inflate.inflate(s[2])
    is_editor = EDITOR_SIGNATURES.any? { |sig| decompressed.include?(sig) }
    if is_editor
      deleted_count += 1
      true
    else
      false
    end
  rescue
    false  # Si no se puede descomprimir, no tocar
  end
end

if deleted_count > 0
  puts "🔄 Editores anteriores eliminados: #{deleted_count}"
end

# Insertar el nuevo editor
new_script = [scripts[0][0], "Ultimate Editor", compressed_code]
scripts.insert(insert_index, new_script)
puts "✅ Ultimate Editor inyectado correctamente"

# Guardar
puts "💾 Guardando cambios..."
File.open(scripts_path, "wb") { |f| Marshal.dump(scripts, f) }

puts ""
puts "=" * 70
puts "✅¡INYECCIÓN COMPLETADA!"
puts "=" * 70
puts ""
puts "🎮 CARACTERÍSTICAS:"
puts "   • Edición manual de IVs (stat por stat)"
puts "   • Edición manual de EVs (stat por stat)"
puts "   • Edición manual de Felicidad (0-255)"
puts "   • 21 naturalezas disponibles"
puts "   • Cambio de habilidades (incluye ocultas)"
puts "   • Cambio de género"
puts "   • Información completa de Pokémon"
puts "   • IVs perfectos rápidos"
puts "   • Felicidad máxima rápida (255)"
puts "   • Visualización de IVs/EVs del party"
puts ""
puts "💡 ACCESO EN EL JUEGO:"
puts "   Presiona F9 mientras juegas para abrir el editor"
puts ""
puts "⚠️  IMPORTANTE:"
puts "   • Guarda tu partida después de hacer cambios"
puts "   • El backup está en: #{backup_path}"
puts ""
puts "=" * 70