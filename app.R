library(shiny)
library(bslib)

ui <- page_fluid(
  title = "Simple Quarto Integration",
  
  # Quarto info section with individually identifiable elements
  h3("Quarto Information"),
  
  # Individual elements with unique IDs for easy targeting
  div(id = "quarto_version_section", 
      strong("Quarto Version:"),
      pre(id = "quarto_version", class = "shiny-text-output")
  ),
  
  div(id = "quarto_path_section",
      strong("Quarto Path:"),
      pre(id = "quarto_path", class = "shiny-text-output")
  ),
  
  div(id = "system_check_section",
      strong("Direct System Check:"),
      pre(id = "system_check", class = "shiny-text-output")
  ),
  
  div(id = "r_version_section",
      strong("R Version:"),
      pre(id = "r_version", class = "shiny-text-output")
  ),
  
  # QMD content card stays the same
  card(
    card_header("Quarto Document"),
    card_body(
      textAreaInput("qmd_content", "QMD Content:", 
                    value = "## Hello Quarto\n\nThis is **bold** and *italic* text.\n\n```{r}\n# Simple R code example\nplot(1:10, main=\"Demo Plot\")\n```\n\nYou can also include equations: $E = mc^2$",
                    height = "200px", width = "100%"),
      downloadButton("download_qmd", "Download .qmd", class = "btn-primary")
    )
  )
)

server <- function(input, output, session) {
  # Individual outputs for each piece of information
  output$quarto_version <- renderText({
    has_quarto <- requireNamespace("quarto", quietly = TRUE)
    if (has_quarto) {
      tryCatch({
        version <- quarto::quarto_version()
        if (is.list(version)) version <- paste(as.character(version), collapse = ", ")
        return(version)
      }, error = function(e) { return(paste("Error:", e$message)) })
    } else {
      return("Quarto package not installed")
    }
  })
  
  output$quarto_path <- renderText({
    has_quarto <- requireNamespace("quarto", quietly = TRUE)
    if (has_quarto) {
      tryCatch({
        path <- quarto::quarto_path()
        if (is.list(path)) path <- paste(as.character(path), collapse = ", ")
        return(path)
      }, error = function(e) { return(paste("Error:", e$message)) })
    } else {
      return("Not available")
    }
  })
  
  output$system_check <- renderText({
    cmd <- if (.Platform$OS.type == "windows") "where quarto 2>NUL" else "which quarto 2>/dev/null"
    tryCatch({
      result <- system(cmd, intern = TRUE)
      return(paste(result, collapse = "\n"))
    }, error = function(e) { return(paste("System check failed:", e$message)) })
  })
  
  output$r_version <- renderText({
    return(R.version.string)
  })
  
  # Download handler stays the same
  output$download_qmd <- downloadHandler(
    filename = function() { "document.qmd" },
    content = function(file) { writeLines(input$qmd_content, file) }
  )
}

shinyApp(ui, server)
