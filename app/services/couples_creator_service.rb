require_relative './application_service'

class CouplesCreator < ApplicationService
  def initialize(game)
    @game = game
  end

  def call
    create_couples
  end

  private

  def create_couples
    workers = Worker.order(:id).to_a

    # Seleccionamos el empleado que no jugara este año.
    if workers.size.odd?
      worker_without_a_pair = select_worker_that_will_not_play(workers)
      workers.delete(worker_without_a_pair) 
      create_and_save_worker_without_a_pair(worker_without_a_pair)
    end

    # Generamos y creamos las parejas.
    couples = generate_couples(workers)
    create_and_save_couples(couples)
  end

  # Selecciona un trabajador que no haya jugado el año anterior.
  def select_worker_that_will_not_play(workers)
    game_last_year = Game.find_by(year_game: @game.year_game - 1)
    game_two_years_ago = Game.find_by(year_game: @game.year_game - 2)
    game_next_year = Game.find_by(year_game: @game.year_game + 1)

    worker_last_year = game_last_year&.worker_without_a_pair&.worker
    worker_two_years_ago = game_two_years_ago&.worker_without_a_pair&.worker
    worker_next_year = game_next_year&.worker_without_a_pair&.worker

    excluded_workers = [worker_last_year, worker_two_years_ago, worker_next_year].compact

    possible_workers_without_pairs = workers.reject { |worker| excluded_workers.include?(worker) }
    worker_without_a_pair = possible_workers_without_pairs.sample

    worker_without_a_pair
  end

  # Genera las parejas del juego.
  def generate_couples(workers)
    possible_worker_combinations = generate_possible_couples(workers)
    couples_last_year = load_couples_from_game(@game.year_game - 1)
    couples_two_years_ago = load_couples_from_game(@game.year_game - 2)

    possible_couples = possible_worker_combinations - couples_last_year - couples_two_years_ago

    selected_couples = select_couples(possible_couples, workers)

    selected_couples
  end

  # Carga las parejas de un juego en especifico.
  def load_couples_from_game(year_game)
    game = Game.find_by(year_game: year_game)
    couples = Couple.where(game_id: game&.id).to_a
    worker_pairs_from_couples(couples)
  end

  # Convierte un array de Couples a un array de parejas de Workers.
  def worker_pairs_from_couples(couples)
    couples.map { |couple| [couple.first_worker, couple.second_worker] }
  end

  # Genera todas las posibles parejas de trabajadores.
  def generate_possible_couples(workers)
    workers.combination(2).to_a
  end

  # Selecciona un conjunto de parejas de trabajadores sin repetir trabajadores
  def select_couples(couple_combinations, workers)
    number_of_couples = workers.size / 2
    possible_combinations = couple_combinations.combination(number_of_couples)

    # Obtiene el conjunto de parejas en el cual no se repita ninguno.
    possible_combinations.find do |couples_set|
      couples_set.flatten.uniq.length == couples_set.flatten.length
    end
  end

  # Crea y guarda en la base de datos las parejas.
  def create_and_save_couples(couples)
    couples.each do |first_worker, second_worker|
      Couple.create(game_id: @game.id, first_worker_id: first_worker.id, second_worker_id: second_worker.id)
    end
  end

  # Crea y guarda en la base de datos un trabajador sin pareja.
  def create_and_save_worker_without_a_pair(worker_without_a_pair)
    WorkerWithoutAPair.create(game_id: @game.id, worker_id: worker_without_a_pair.id).save
  end

end