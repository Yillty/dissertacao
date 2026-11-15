packages = c("did", "jsonlite", "arrow", "dplyr", "ggplot2", "glue")
options(repos = c(CRAN = "https://cloud.r-project.org"))

for (pkg in packages){
  print("---------------------------------------------------------")
  if (!requireNamespace(pkg, quietly = TRUE)){
    print(paste0("Package ", pkg," missing: initializing download"))
    print("---------------------------------------------------------")
    install.packages(pkg)
    print("---------------------------------------------------------")
    print(paste0(pkg," installed!"))
  } else{
    print(paste0("Package", pkg," present. Continuing"))
  }
}

print("---------------------------------------------------------")
print("opening packages")
library(did)
library(jsonlite)
library(arrow)
library(dplyr)
library(ggplot2)
library(glue)
print("done")
print("---------------------------------------------------------")

# Variáveis importantes
alp <- 0.10 # nível de significância
name <- 'dba' # nome da base de dados, é usado para lê-la e salvar os resultados

print("reading file")
dbj <- read_parquet(glue("Tratamento de Dados/{name}.parquet"))
print("done")
print("---------------------------------------------------------")

print("regression")
regj_attgt <- att_gt(yname = 'y',
                     tname = 'year',
                     idname = 'id',
                     gname = 'group',
                     data = dbj,
                     xformla = ~ age,
                     print_details = FALSE,
                     allow_unbalanced_panel = TRUE,
                     est_method = "dr",
                     faster_mode = FALSE,
                     control_group = 'nevertreated',
                     alp = alp)


summary(regj_attgt)
capture.output(summary(regj_attgt), file = glue("Resultados/att_gt({name}).txt"))

p <- ggdid(regj_attgt)
ggsave(glue("Resultados/Imagens/desagregado({name}).png"), plot =  p, width = 15, height = 15, dpi = 300)

regj_attge <- aggte(regj_attgt, 
                   alp = alp, type = 'group')

capture.output(regj_attge, file = glue("Resultados/attge({name}).txt"))

p <- ggdid(regj_attge)
ggsave(glue("Resultados/Imagens/{name}-reg.png"), plot =  p, width = 8, height = 8, dpi = 300)

summary(regj_attge)

