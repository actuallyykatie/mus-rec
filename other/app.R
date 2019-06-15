library(data.table)
library(dplyr)
library(tidyverse)

library(shiny)
library(shinycssloaders)
library(shinythemes)
library(shinyWidgets)
library(shiny.semantic)
library(shinyalert)
library(shinyjs)

library(reticulate)

# пакетик из питона
gensim = import("gensim")
# модель
model = gensim$models$Word2Vec$load('musrec/w2v_90m.model')

# список исполнителей для ворд2век
artists = read_csv('musrec/artistsChoice.csv')
colnames(artists) = c('X1','artist')
selectList = artists$artist


# Define UI 
ui = fluidPage(
  #theme = shinytheme("simplex"),  # simplex если светленькая, darkly - темная
  theme = shinytheme("darkly"),
  setBackgroundImage(src = "https://pp.userapi.com/c848632/v848632986/1b37fe/qW7YKo71fEQ.jpg"),
  # Название приложения
  titlePanel("Music Recommender 🎶"),
  
  # Sidebar 
  # задает расположение элементов (сайдбар и основная часть)
  sidebarLayout(
    sidebarPanel(  # боковая панель; управляющие элементы 
      # Текст с небольшими инструкциями для пользователя ----
      useShinyalert(),  # Set up shinyalert
      actionButton("preview", "How does it work?", style='padding:4px; font-size:80%; margin-bottom:10px;'),
      
      # Ввод: выбор исполнителя  ----
      selectizeInput(inputId="pos_artists", label="Choose artists:",
                     choices = NULL,
                     options = list(maxOptions = 7),
                     multiple = TRUE,
                     selected = 1
      ),
      # Ввод: Желаемое число результатов ----
      numericInput("num_res", "Number of recommendations:", min = 1, max = 30, value = 10),
      
      # Ввод: actionButton() получить рекомендации ----
      # Дает возможность получать рекомендации когда пользователь закончит ввод.
      # Было очень полезно при предыдущем типе ввода, когда пользователь сам вводил слова
      #, т.к. когда слово еще не было введено не до конца, модель почти сразу 
      # показывала out of vocab в real-time. 
      # Сейчас учитывается выбор числа желаемых рекомендаций и выбор исполнителя.
      actionButton("submit", "Recommend!")
    ),
    
    
    # колоночка справа с рекомендациями
    mainPanel(
      fluidRow(column(7, verbatimTextOutput("value"))),
      # прикольно показывается спиннер пока табличка и вот это вот всё строится (type = 6 - nice one)
      tabPanel("Table", tableOutput("table")  %>% withSpinner())
    )
  )
)

# Define server logic 
server = function(input, output, session) {
  
  # Message
  observeEvent(input$preview, {
    # Месседж о том что как работает
    shinyalert("Hello!", "Simply choose one or more artists whose 
               songs are somewhat related to your current mood, 
               and app will recommend you more.\n
               The model is built using word2vec and 90M dataset 
               with music playlists. Sometimes model recommends 
               same artists due to the data 
               ¯\\_(ツ)_/¯", type = "info")
  })
  
  # Для поддержки мультипул инпута, т.к. вариантов для выбора очень много, лучше делать со стороны сервера.
  updateSelectizeInput(session = session, inputId = 'pos_artists',
                       choices = c(Choose = '', selectList), server = TRUE)
  
  # Рекомендации
  observeEvent(input$submit, {
    toggle("hideme")
    output$table = renderTable({
      # Реагируем на кнопку 
      input$submit
      
      # Используем isolate(), чтобы результат модели не обновлялся каждый раз когда что-то поменялось.
      # В теории, сейчас можно обойтись и без него.
      inp_art_POS = isolate(tolower(input$pos_artists))
      inp_num = isolate(input$num_res)
      
      # Используя немного манипуляций и модель из python, выдаем n результатов для пользователя
      # Получаем аутпут
      modelOutput = reactive({
        df = matrix(unlist(model$wv$most_similar(positive = inp_art_POS, 
                                                 topn = as.integer(inp_num))), 
                    ncol=2 , byrow=T, dimnames = list(seq(inp_num), c('Artist', 'Similarity')))
      })
      # Делаем из него табличку
      df_output = as.data.frame(x=modelOutput())
      
      # Выводим
      df_output 
    }
    , width = '75%')
    
  })
  
  
  }


shinyApp(ui = ui, server = server)

