library(shiny)
library(bslib)

ui <- page_fluid(
  title = "Simple Quarto Integration",
  
  # Quarto info with specific ID for easier testing
  h3("Quarto Information"),
  div(
    id = "quarto-version-container",
    class = "quarto-info",
    verbatimTextOutput("quarto_version")
  ),
  
  # QMD content and download card
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
  # Display Quarto version information
  output$quarto_version <- renderPrint({
    # Check if quarto package is available
    has_quarto <- requireNamespace("quarto", quietly = TRUE)
    
    if (has_quarto) {
      # Try to get quarto version - with better error handling
      tryCatch({
        # Handle the case when quarto_version returns a list
        version <- quarto::quarto_version()
        if (is.list(version)) {
          cat("Quarto version information is a list - converting to string\n")
          version_str <- as.character(version)
          cat("Quarto version: ", paste(version_str, collapse = ", "), "\n")
        } else {
          cat("Quarto version: ", version, "\n")
        }
        
        # Same for path
        path <- quarto::quarto_path()
        if (is.list(path)) {
          path_str <- as.character(path)
          cat("Quarto path: ", paste(path_str, collapse = ", "), "\n")
        } else {
          cat("Quarto path: ", path, "\n")
        }
        
        # Try direct system call as fallback
        cat("\nDirect system check:\n")
        if (.Platform$OS.type == "windows") {
          system("where quarto 2>NUL", intern = TRUE)
        } else {
          system("which quarto 2>/dev/null", intern = TRUE)
        }
      }, error = function(e) {
        cat("Error getting Quarto information: ", e$message, "\n")
        
        # Try direct system call as fallback
        cat("\nAttempting direct system check:\n")
        tryCatch({
          if (.Platform$OS.type == "windows") {
            result <- system("where quarto 2>NUL", intern = TRUE)
            cat("System found quarto at: ", paste(result, collapse = "\n"), "\n")
          } else {
            result <- system("which quarto 2>/dev/null", intern = TRUE)
            cat("System found quarto at: ", paste(result, collapse = "\n"), "\n")
          }
        }, error = function(e2) {
          cat("System check also failed: ", e2$message, "\n")
        })
      })
    } else {
      cat("Quarto package is not installed.\n")
      cat("To install, run: install.packages('quarto')\n")
    }
    
    # Additional system information for context
    cat("\nSystem information:\n")
    cat("R version: ", R.version.string, "\n")
    cat("Platform: ", .Platform$OS.type, "\n")
    cat("PATH: ", Sys.getenv("PATH"), "\n")
  })
  
  # Handle download of qmd file
  output$download_qmd <- downloadHandler(
    filename = function() {
      "document.qmd"
    },
    content = function(file) {
      writeLines(input$qmd_content, file)
    }
  )
}

shinyApp(ui, server)
