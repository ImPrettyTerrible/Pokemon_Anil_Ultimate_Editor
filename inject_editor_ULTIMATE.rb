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
  puts "Uso: ruby inject_ultimate_editor_fixed_abilities.rb <ruta_a_Scripts.rxdata>"
  exit 0
end

scripts_path = ARGV[0]

unless File.exist?(scripts_path)
  abort "❌ No se encuentra: #{scripts_path}"
end

# Crear backup
backup_path = scripts_path + ".backup"
unless File.exist?(backup_path)
  require 'fileutils'
  FileUtils.cp(scripts_path, backup_path)
  puts "Backup creado: #{backup_path}"
end

# Cargar scripts
scripts = Marshal.load(File.binread(scripts_path))

# Código ULTIMATE con habilidades FIXED
ultimate_code = <<'RUBY_CODE'
p "Editor Ultimate cargando..."

def pbPerfectIVs
  p "IVs perfectos aplicados"
  return if !$Trainer || !$Trainer.party
  $Trainer.party.each do |pkmn|
    next if !pkmn
    6.times { |i| pkmn.iv[i] = 31 }
    pkmn.calcStats rescue nil
  end
  Kernel.pbMessage("IVs perfectos aplicados a todo el party") rescue nil
end

def pbShowIVs
  return if !$Trainer || !$Trainer.party
  msg = "IVs del Party:"
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn
    msg += "\n#{i+1}. #{pkmn.name}: #{pkmn.iv.join(',')}"
  end
  Kernel.pbMessage(msg) rescue nil
end

def pbShowEVs
  return if !$Trainer || !$Trainer.party
  msg = "EVs del Party:"
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn
    msg += "\n#{i+1}. #{pkmn.name}: HP#{pkmn.ev[0]} Atk#{pkmn.ev[1]} Def#{pkmn.ev[2]} SpA#{pkmn.ev[3]} SpD#{pkmn.ev[4]} Spe#{pkmn.ev[5]}"
  end
  Kernel.pbMessage(msg) rescue nil
end

def pbSelectPokemon
  return nil if !$Trainer || !$Trainer.party || $Trainer.party.empty?
  
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
  return if !pkmn
  p "Editando IVs manualmente de #{pkmn.name}"
  
  stats = ["HP", "Ataque", "Defensa", "Atq. Esp.", "Def. Esp.", "Velocidad"]
  
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
  return if !pkmn
  p "Editando EVs manualmente de #{pkmn.name}"
  
  stats = ["HP", "Ataque", "Defensa", "Atq. Esp.", "Def. Esp.", "Velocidad"]
  
  loop do
    current_total = pkmn.ev[0] + pkmn.ev[1] + pkmn.ev[2] + pkmn.ev[3] + pkmn.ev[4] + pkmn.ev[5]
    commands = []
    stats.each_with_index do |stat, i|
      commands.push("#{stat}: #{pkmn.ev[i]}")
    end
    commands.push("Resetear EVs", "Volver")
    
    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 7
    break if cmd == 7 || cmd.nil?
    
    if cmd >= 0 && cmd < 6
      params = ChooseNumberParams.new
      params.setRange(0, 252)
      params.setDefaultValue(pkmn.ev[cmd])
      params.setCancelValue(-1)
      new_ev = Kernel.pbMessageChooseNumber("Nuevo EV para #{stats[cmd]} (0-252):", params) rescue -1
      
      if new_ev >= 0
        new_total = (pkmn.ev[0] + pkmn.ev[1] + pkmn.ev[2] + pkmn.ev[3] + pkmn.ev[4] + pkmn.ev[5]) - pkmn.ev[cmd] + new_ev
        
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
  return if !pkmn
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
  return if !pkmn
  p "Editando habilidad de #{pkmn.name}"
  
  # Obtener lista de habilidades posibles
  abilities = pkmn.getAbilityList
  return if !abilities || abilities.empty?
  
  commands = []
  ability_ids = []
  
  abilities.each do |ability_data|
    ability_id = ability_data[0]
    ability_name = PBAbilities.getName(ability_id) rescue "Habilidad #{ability_id}"
    is_hidden = (ability_data[1] == 2) # 2 = Hidden Ability
    
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
  
  # Cambiar habilidad - MÉTODO COMPATIBLE
  new_ability = ability_ids[cmd]
  old_ability_name = PBAbilities.getName(pkmn.ability) rescue "Habilidad #{pkmn.ability}"
  new_ability_name = PBAbilities.getName(new_ability) rescue "Habilidad #{new_ability}"
  
  p "Intentando cambiar habilidad de #{old_ability_name} a #{new_ability_name}"
  
  success = false
  method_used = "Ninguno"
  
  # MÉTODO 1: setAbility (más común)
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
  
  # MÉTODO 2: Variable de instancia @ability
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
  
  # MÉTODO 3: ability_index (alternativa común)
  if !success && pkmn.respond_to?(:ability_index)
    begin
      # Encontrar el índice de la habilidad seleccionada
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
  
  # MÉTODO 4: Forzar habilidad oculta con flag especial
  if !success
    begin
      p "Intentando forzar habilidad oculta con flag..."
      
      # Método específico para habilidades ocultas
      if pkmn.respond_to?(:setAbility) && abilities[cmd][1] == 2 # Es habilidad oculta
        # Intentar marcar como Pokémon con habilidad oculta
        if pkmn.respond_to?(:abilityflag)
          pkmn.abilityflag = 2
        end
        
        # Forzar la habilidad
        pkmn.setAbility(new_ability)
        success = (pkmn.ability == new_ability)
        method_used = "Forzar oculta" if success
        p "✅ Habilidad oculta forzada" if success
      end
    rescue => e
      p "❌ Error forzando habilidad oculta: #{e.message}"
    end
  end
  
  # MÉTODO 5: Recreación SIMPLE del Pokémon con habilidad forzada
  if !success
    begin
      p "Intentando recreación simple con habilidad forzada..."
      
      # Guardar datos esenciales
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
      
      # Crear nuevo Pokémon
      new_pkmn = PokeBattle_Pokemon.new(pkmn.species, temp_level)
      
      # Restaurar datos básicos
      new_pkmn.iv = temp_iv
      new_pkmn.ev = temp_ev
      new_pkmn.exp = temp_exp
      new_pkmn.item = temp_item
      new_pkmn.ot = temp_ot
      new_pkmn.otgender = temp_otgender
      new_pkmn.id = temp_id
      new_pkmn.name = temp_name
      
      # Restaurar movimientos
      temp_moves.each_with_index do |move_id, i|
        if move_id && move_id > 0
          new_pkmn.moves[i] = PBMove.new(move_id)
        end
      end
      
      # FORZAR HABILIDAD - Múltiples métodos
      if new_pkmn.respond_to?(:setAbility)
        new_pkmn.setAbility(new_ability)
      end
      
      if new_pkmn.instance_variable_defined?(:@ability)
        new_pkmn.instance_variable_set(:@ability, new_ability)
      end
      
      # Marcar como habilidad oculta si corresponde
      if abilities[cmd][1] == 2 # Habilidad oculta
        if new_pkmn.respond_to?(:abilityflag=)
          new_pkmn.abilityflag = 2
        elsif new_pkmn.instance_variable_defined?(:@abilityflag)
          new_pkmn.instance_variable_set(:@abilityflag, 2)
        end
      end
      
      # Reemplazar en el party
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
  
  # MÉTODO 6: Último intento - Cambiar species temporalmente
  if !success && abilities[cmd][1] == 2 # Solo para habilidades ocultas
    begin
      p "Último método: cambio temporal de species..."
      
      temp_species = pkmn.species
      
      # Cambiar a una species temporal y volver
      if pkmn.respond_to?(:species=)
        pkmn.species = 1 # Bulbasaur temporal
        pkmn.species = temp_species
        
        # Intentar cambiar habilidad nuevamente
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
  
  # Verificar resultado
  final_ability = pkmn.ability
  final_ability_name = PBAbilities.getName(final_ability) rescue "Habilidad #{final_ability}"
  
  if success
    p "✅ Habilidad cambiada exitosamente a #{final_ability_name} (método: #{method_used})"
    Kernel.pbMessage("✅ Habilidad cambiada: #{old_ability_name} → #{final_ability_name}") rescue nil
    # Recalcular stats
    pkmn.calcStats rescue nil
    
    # Si es habilidad oculta, mostrar mensaje especial
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
  return if !pkmn
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
  when 0 then 0 # Macho
  when 1 then 1 # Hembra
  when 2 then 2 # Sin género
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

def pbShowPokemonInfo(pkmn)
  return if !pkmn
  p "Mostrando info de #{pkmn.name}"
  
  gender_str = case pkmn.gender
  when 0 then "Macho"
  when 1 then "Hembra" 
  else "Sin género"
  end
  
  ability_name = PBAbilities.getName(pkmn.ability) rescue "Habilidad #{pkmn.ability}"
  nature_name = PBNatures.getName(pkmn.nature) rescue "Naturaleza #{pkmn.nature}"
  
  info = "Información de #{pkmn.name}:\n"
  info += "Nivel: #{pkmn.level}\n"
  info += "Género: #{gender_str}\n"
  info += "Naturaleza: #{nature_name}\n"
  info += "Habilidad: #{ability_name}\n"
  info += "IVs: HP#{pkmn.iv[0]} Atk#{pkmn.iv[1]} Def#{pkmn.iv[2]} SpA#{pkmn.iv[3]} SpD#{pkmn.iv[4]} Spe#{pkmn.iv[5]}\n"
  info += "EVs: HP#{pkmn.ev[0]} Atk#{pkmn.ev[1]} Def#{pkmn.ev[2]} SpA#{pkmn.ev[3]} SpD#{pkmn.ev[4]} Spe#{pkmn.ev[5]}\n"
  info += "Total EVs: #{(pkmn.ev[0] + pkmn.ev[1] + pkmn.ev[2] + pkmn.ev[3] + pkmn.ev[4] + pkmn.ev[5])}/510"
  
  Kernel.pbMessage(info) rescue nil
end

def pbUltimateEditor
  p "Editor Ultimate abierto"
  
  loop do
    commands = [
      "Editar IVs manualmente",
      "Editar EVs manualmente", 
      "Cambiar Naturaleza",
      "Cambiar Habilidad",
      "Cambiar Género",
      "Ver Info Completa",
      "IVs perfectos a todos",
      "Ver IVs del party",
      "Ver EVs del party",
      "Cancelar"
    ]
    
    cmd = Kernel.pbShowCommands(nil, commands, -1) rescue 9
    break if cmd == 9 || cmd.nil?
    
    case cmd
    when 0
      slot = pbSelectPokemon
      pbEditIVsManual($Trainer.party[slot]) if slot
    when 1
      slot = pbSelectPokemon
      pbEditEVsManual($Trainer.party[slot]) if slot
    when 2
      slot = pbSelectPokemon
      pbEditNature($Trainer.party[slot]) if slot
    when 3
      slot = pbSelectPokemon
      pbEditAbility($Trainer.party[slot]) if slot
    when 4
      slot = pbSelectPokemon
      pbEditGender($Trainer.party[slot]) if slot
    when 5
      slot = pbSelectPokemon
      pbShowPokemonInfo($Trainer.party[slot]) if slot
    when 6
      pbPerfectIVs
    when 7
      pbShowIVs
    when 8
      pbShowEVs
    end
  end
end

# Hook en Scene_Map
if defined?(Scene_Map)
  class Scene_Map
    alias ultimate_editor_update update
    def update
      ultimate_editor_update
      if Input.trigger?(Input::F9)
        p "F9 presionado - Abriendo editor ULTIMATE"
        pbUltimateEditor
      end
    end
  end
  p "Editor Ultimate instalado correctamente"
end

p "Editor Ultimate completamente cargado"
RUBY_CODE

# Comprimir
compressed_code = Zlib::Deflate.deflate(ultimate_code)

# Buscar Main
insert_index = scripts.length - 1
scripts.each_with_index do |script, i|
  next if !script || !script[1]
  if script[1] =~ /^Main$/i
    insert_index = i
    break
  end
end

# Insertar nuevo script
new_script = [scripts[0][0], "Ultimate Editor", compressed_code]
scripts.insert(insert_index, new_script)

# Guardar
File.open(scripts_path, "wb") { |f| Marshal.dump(scripts, f) }
puts "✅ Editor ULTIMATE FINAL inyectado."
puts ""
puts "✨ Características finales:"
puts "   ✅ Cambio de IVs manual y perfectos"
puts "   ✅ Cambio de EVs manual y reset"
puts "   ✅ 21 naturalezas incluyendo SERIOUS (Única naturaleza Neutral disponible)"
puts "   ✅ Cambio de habilidades normales y OCULTAS"
puts "   ✅ Cambio de género"
puts "   ✅ Info completa de Pokémon"
puts ""

puts "🎮 ACCESO: Presiona F9 en el juego para abrir el editor"
