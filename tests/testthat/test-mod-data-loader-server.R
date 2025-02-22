### TESTSERVER tests
test_that("loads example data", {
  nm_file <- system.file("extdata", "null_model.RData", package="GENESISModelExplorer")
  pheno_file <- system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")
  geno_file <- system.file("extdata", "genotypes.rds", package="GENESISModelExplorer")
  dat <- .load_data(nm_file, pheno_file, genotype_filename = geno_file)

  testServer(mod_data_loader_server, {
    session$setInputs(use_example_data = TRUE)
    expect_true(stringr::str_detect(output$selected_null_model_file, nm_file))
    expect_true(stringr::str_detect(output$selected_phenotype_file, pheno_file))
    session$setInputs(load_data_button = TRUE)
    expect_equal(data_reactive(), dat)
    expect_equal(output$data_loaded_message, "900 samples loaded")
    returned <- session$getReturned()
    expect_equal(returned(), dat)
  })
})

### TESTSERVER tests
test_that("does not load without button - example data", {
  testServer(mod_data_loader_server, {
    session$setInputs(use_example_data = TRUE)
    expect_true(stringr::str_detect(output$selected_null_model_file, system.file("extdata", "null_model.RData", package="GENESISModelExplorer")))
    expect_true(stringr::str_detect(output$selected_phenotype_file, system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")))
    # Is this appropriate?
    expect_error(data_reactive())
    returned <- session$getReturned()
    expect_error(returned())
  })
})

test_that("does not load without button - user data", {
  nm_file <- system.file("extdata", "null_model.RData", package="GENESISModelExplorer")
  pheno_file <- system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")
  skip("Update for shinyFiles")

  testServer(mod_data_loader_server, {
    session$setInputs(use_example_data = FALSE)
    session$setInputs(null_model_file = list(datapath = nm_file))
    session$setInputs(phenotype_file = list(datapath = pheno_file))
    # Is this appropriate?
    expect_error(data_reactive())
    returned <- session$getReturned()
    expect_error(returned())
  })
})

test_that("loads user data", {
  tmp_pheno <- get(load(system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")))
  user_pheno_file <- withr::local_file("pheno.RData")
  save(tmp_pheno, file = user_pheno_file)

  # Temporary null model file with fewer samples.
  user_nullmod_file <- withr::local_file("nullmod.RData")
  null_model <- get(load(system.file("extdata", "null_model.RData", package="GENESISModelExplorer")))
  null_model$fit <- null_model$fit[1:100, ]
  save(null_model, file = user_nullmod_file)

  dat <- .load_data(user_nullmod_file, user_pheno_file)

  skip("Update for shinyFiles")
  testServer(mod_data_loader_server, {
    session$setInputs(use_example_data = FALSE)
    session$setInputs(null_model_file = list(datapath = user_nullmod_file))
    session$setInputs(phenotype_file = list(datapath = user_pheno_file))
    expect_true(stringr::str_detect(output$selected_null_model_file, user_nullmod_file))
    expect_true(stringr::str_detect(output$selected_phenotype_file, user_pheno_file))
    session$setInputs(load_data_button = TRUE)
    expect_equal(data_reactive(), dat)
    expect_equal(output$data_loaded_message, "100 samples loaded")
    returned <- session$getReturned()
    expect_equal(returned(), dat)
  })
})

test_that("loads user data with genotype", {
  tmp_pheno <- get(load(system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")))
  user_pheno_file <- withr::local_file("pheno.RData")
  save(tmp_pheno, file = user_pheno_file)

  tmp_geno <- readRDS(system.file("extdata", "genotypes.rds", package="GENESISModelExplorer"))
  user_geno_file <- withr::local_file("geno.RData")
  saveRDS(tmp_geno, file = user_geno_file)

  # Temporary null model file with fewer samples.
  user_nullmod_file <- withr::local_file("nullmod.RData")
  null_model <- get(load(system.file("extdata", "null_model.RData", package="GENESISModelExplorer")))
  null_model$fit <- null_model$fit[1:100, ]
  save(null_model, file = user_nullmod_file)

  dat <- .load_data(user_nullmod_file, user_pheno_file, genotype_filename = user_geno_file)

  skip("Update for shinyFiles")
  testServer(mod_data_loader_server, {
    session$setInputs(use_example_data = FALSE)
    session$setInputs(null_model_file = list(datapath = user_nullmod_file))
    session$setInputs(phenotype_file = list(datapath = user_pheno_file))
    session$setInputs(genotype_file = list(datapath = user_geno_file))
    expect_true(stringr::str_detect(output$selected_null_model_file, user_nullmod_file))
    expect_true(stringr::str_detect(output$selected_phenotype_file, user_pheno_file))
    expect_true(stringr::str_detect(output$selected_genotype_file, user_geno_file))
    session$setInputs(load_data_button = TRUE)
    expect_equal(data_reactive(), dat)
    expect_equal(output$data_loaded_message, "100 samples loaded")
    returned <- session$getReturned()
    expect_equal(returned(), dat)
  })
})

test_that("fails when only null model file is specified", {
  tmp_pheno <- get(load(system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")))
  user_pheno_file <- withr::local_file("pheno.RData")
  save(tmp_pheno, file = user_pheno_file)

  # Temporary null model file with fewer samples.
  user_nullmod_file <- withr::local_file("nullmod.RData")
  null_model <- get(load(system.file("extdata", "null_model.RData", package="GENESISModelExplorer")))
  null_model$fit <- null_model$fit[1:100, ]
  save(null_model, file = user_nullmod_file)

  skip("Update for shinyFiles")
  expect_error(
    testServer(mod_data_loader_server, {
      session$setInputs(use_example_data = FALSE)
      session$setInputs(null_model_file = list(datapath = user_nullmod_file))
      session$setInputs(load_data_button = TRUE)
      expect_equal(data_reactive(), NULL)
      expect_equal(output$data_loaded_message, "")
      returned <- session$getReturned()
      expect_equal(returned(), NULL)
    }),
    "^Please select a phenotype file."
  )
})

test_that("fails when only phenotype file is specified", {
  tmp_pheno <- get(load(system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")))
  user_pheno_file <- withr::local_file("pheno.RData")
  save(tmp_pheno, file = user_pheno_file)

  # Temporary null model file with fewer samples.
  user_nullmod_file <- withr::local_file("nullmod.RData")
  null_model <- get(load(system.file("extdata", "null_model.RData", package="GENESISModelExplorer")))
  null_model$fit <- null_model$fit[1:100, ]
  save(null_model, file = user_nullmod_file)

  skip("Update for shinyFiles")
  expect_error(
    testServer(mod_data_loader_server, {
      session$setInputs(use_example_data = FALSE)
      session$setInputs(phenotype_file = list(datapath = user_pheno_file))
      session$setInputs(load_data_button = TRUE)
      expect_equal(data_reactive(), NULL)
      expect_equal(output$data_loaded_message, "")
      returned <- session$getReturned()
      expect_equal(returned(), NULL)
    }),
    "^Please select a null model file.$"
  )
})

test_that("fails when only genotype file is specified", {
  tmp_pheno <- get(load(system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")))
  user_pheno_file <- withr::local_file("pheno.RData")
  save(tmp_pheno, file = user_pheno_file)

  tmp_geno <- readRDS(system.file("extdata", "genotypes.rds", package="GENESISModelExplorer"))
  user_geno_file <- withr::local_file("geno.RData")
  save(tmp_geno, file = user_geno_file)

  # Temporary null model file with fewer samples.
  user_nullmod_file <- withr::local_file("nullmod.RData")
  null_model <- get(load(system.file("extdata", "null_model.RData", package="GENESISModelExplorer")))
  null_model$fit <- null_model$fit[1:100, ]
  save(null_model, file = user_nullmod_file)

  skip("Update for shinyFiles")
  expect_error(
    testServer(mod_data_loader_server, {
      session$setInputs(use_example_data = FALSE)
      session$setInputs(genotype_file = list(datapath = user_geno_file))
      session$setInputs(load_data_button = TRUE)
      expect_equal(data_reactive(), NULL)
      expect_equal(output$data_loaded_message, "")
      returned <- session$getReturned()
      expect_equal(returned(), NULL)
    }),
    "^Please select a null model file.$"
  )
})

test_that("loads example data over user data when box is checked", {
  example_pheno_file <- system.file("extdata", "phenotype.RData", package="GENESISModelExplorer")
  tmp_pheno <- get(load(example_pheno_file))
  user_pheno_file <- withr::local_file("pheno.RData")
  save(tmp_pheno, file = user_pheno_file)

  # Temporary null model file with fewer samples.
  example_nullmod_file <- system.file("extdata", "null_model.RData", package="GENESISModelExplorer")
  user_nullmod_file <- withr::local_file("nullmod.RData")
  null_model <- get(load(example_nullmod_file))
  null_model$fit <- null_model$fit[1:100, ]
  save(null_model, file = user_nullmod_file)

  dat <- .load_data(example_nullmod_file, example_pheno_file)

  skip("Update for shinyFiles")
  testServer(mod_data_loader_server, {
    session$setInputs(use_example_data = TRUE)
    session$setInputs(null_model_file = list(datapath = user_nullmod_file))
    session$setInputs(phenotype_file = list(datapath = user_pheno_file))
    session$setInputs(load_data_button = TRUE)
    expect_equal(data_reactive(), dat)
    expect_equal(output$data_loaded_message, "900 samples loaded")
    returned <- session$getReturned()
    expect_equal(returned(), dat)
  })
})
