setup_overlap_ui <- function(id) {
    ns <- shiny::NS(id)
    tabPanel(
        id,
        fluidPage(
            bar_w_help_and_download("Overlap study", ns("help"), ns("download_settings")),
            fluidRow(
                column(
                    12,
                    wellPanel(
                        fluidRow(
                            column(6, selectInput(ns("dataset1"), "Reference dataset", choices = c("Dev"), selected = "Dev")),
                            column(6, selectInput(ns("dataset2"), "Comp. dataset", choices = c("Dev"), selected = "Dev"))
                        ),
                        conditionalPanel(
                            sprintf("input['%s'] != 'UpsetPresence'", ns("plot_tabs")),
                            fluidRow(
                                column(6, selectInput(ns("ref_contrast"), "Ref. contr.", choices = c("Dev"), selected = "Dev")),
                                column(6, selectInput(ns("comp_contrast"), "Comp. contr.", choices = c("Dev"), selected = "Dev"))
                            ),
                            fluidRow(
                                column(6, sliderInput(ns("stat_threshold"), "Stat. threshold", min=0, max=1, step=0.01, value=0.05)),
                                column(6, selectInput(ns("stat_contrast_type"), "Stat. contrast type", choices=c("P.Value", "adj.P.Val")))
                            ),
                            fluidRow(
                                column(6, sliderInput(ns("fold_threshold"), "Fold threshold", min=0, max=10, step=0.1, value=1)),
                                column(6, checkboxInput(ns("use_fold_cutoff"), "Use fold cutoff", value=FALSE))
                            )
                        ),
                        conditionalPanel(
                            sprintf("input['%s'] == 'UpsetPresence'", ns("plot_tabs")),
                            fluidRow(
                                column(6, selectInput(ns("upset_pres_cond_ref"), "Condition ref.", choices=c(""), selected="")),
                                column(6, selectInput(ns("upset_pres_levels_ref"), "Selected levels ref.", choices=c(""), selected="", multiple=TRUE))
                            ),
                            conditionalPanel(
                                sprintf("input['%s'] != input['%s']", ns("dataset1"), ns("dataset2")),
                                fluidRow(
                                    column(6, selectInput(ns("upset_pres_cond_comp"), "Condition comp.", choices=c(""), selected="")),
                                    column(6, selectInput(ns("upset_pres_levels_comp"), "Selected levels comp.", choices=c(""), selected="", multiple=TRUE))
                                )
                            ),
                            fluidRow(column(12, sliderInput(ns("upset_pres_frac"), "Required minimum fraction to be considered present", value=0, min=0, max=1, step=0.05)))
                        ),
                        fluidRow(
                            column(6, conditionalPanel(
                                sprintf("input['%s'] == 'Venn'", ns("plot_tabs")),
                                selectInput(ns("select_target"), "Select target", choices=c("A", "B", "A&B", "A|B"), selected = "A&B")
                            ))
                        ),
                        conditionalPanel(
                            sprintf("input['%s'] == 'Upset' || input['%s'] == 'FoldComparison'", ns("plot_tabs"), ns("plot_tabs")),
                            selectInput(ns("upset_ref_comparisons"), "Upset ref. choices", choices = c("Dev"), selected="Dev", multiple = TRUE),
                            conditionalPanel(
                                sprintf("input['%s'] != input['%s']", ns("dataset1"), ns("dataset2")),
                                selectInput(ns("upset_comp_comparisons"), "Upset comp. choices", choices = c("Dev"), selected="Dev", multiple = TRUE)
                            )
                        ),
                        conditionalPanel(
                            sprintf("input['%s'] == 'Upset' || input['%s'] == 'UpsetPresence'", ns("plot_tabs"), ns("plot_tabs")),
                            fluidRow(
                                column(6, numericInput(ns("upset_max_comps"), "Upset max comparisons (rows)", min = 1, value = 10)),
                                column(6, numericInput(ns("upset_max_intersects"), "Upset max intersects (columns)", min = 1, value = 40))
                            ),
                            fluidRow(
                                column(6, checkboxInput(ns("upset_degree_order"), "Order on degree", value=FALSE)),
                                conditionalPanel(
                                    sprintf("input['%s'] == 'Upset'", ns("plot_tabs")),
                                    column(6, checkboxInput(ns("fold_split_upset"), "Fold split upset", value=FALSE))
                                )
                            )
                        ),
                        conditionalPanel(
                            sprintf("input['%s'] == 'FoldComparison'", ns("plot_tabs")),
                            numericInput(ns("max_fold_comps"), "Max fold comps", min=1, value=10)
                        ),
                        checkboxInput(ns("advanced_settings"), "Show advanced settings"),
                        conditionalPanel(
                            sprintf("input['%s'] == 1", ns("advanced_settings")),
                            fluidRow(
                                downloadButton(ns("ggplot_download"), "Download static")
                            )
                        )
                    ),
                    # htmlOutput(ns("warnings")),
                    conditionalPanel(
                        sprintf("input['%s'] == 'Upset'", ns("plot_tabs")),
                        wellPanel(
                            h3("Select overlap"),
                            selectInput(ns("upset_crosssec_display"), "Display cross-section", choices = c("Dev"), selected="Dev", multiple = TRUE),
                            textOutput(ns("test_crosssec_display"))
                        )
                    ),
                    conditionalPanel(
                        sprintf("input['%s'] == 'UpsetPresence'", ns("plot_tabs")),
                        wellPanel(
                            h3("Select overlap"),
                            selectInput(ns("upset_crosssec_display_presence"), "Display cross-section (presence)", choices = c("Dev"), selected="Dev", multiple = TRUE)
                        )
                    ),
                    tabsetPanel(
                        id = ns("plot_tabs"),
                        type = "tabs",
                        tabPanel("Venn",
                                 fluidRow(
                                     column(6, plotOutput(ns("venn"))),
                                     column(6, plotOutput(ns("fold_fractions_among_sig")))
                                 ),
                                 actionButton(ns("update_spotcheck"), "Visualize selected features"),
                                 downloadButton(ns("download_table"), "Download table"),
                                 DT::DTOutput(ns("table_display"))
                        ),
                        tabPanel("Upset",
                                 plotOutput(ns("upset"), height = 800) %>% withSpinner(),
                                 actionButton(ns("update_spotcheck_upset"), "Visualize selected features"),
                                 downloadButton(ns("download_table_upset"), "Download table"),
                                 DT::DTOutput(ns("table_display_upset"))
                        ),
                        tabPanel("FoldComparison",
                                 plotOutput(ns("fold_comp"))
                        ),
                        tabPanel("UpsetPresence",
                                 plotOutput(ns("upset_presence"), height = 800) %>% withSpinner(),
                                 actionButton(ns("update_spotcheck_upset_pres"), "Visualize selected features"),
                                 downloadButton(ns("download_table_upset_presence"), "Download table"),
                                 DT::DTOutput(ns("table_display_upset_presence"))
                        )
                    )
                )
            )
        )
    )
}

module_overlap_server <- function(input, output, session, rv, module_name, parent_session=NULL) {
    
    output$download_table <- output$download_table_upset <- output$download_table_upset_presence <- downloadHandler(
        filename = function() {
            paste("overlap-", format(Sys.time(), "%y%m%d_%H%M%S"), ".tsv", sep="")
        },
        content = function(file) {
            write_tsv(rv$dt_parsed_data_raw(rv, output_table_reactive()), file)
        }
    )
    
    output$download_settings <- settings_download_handler("overlap", input)
    
    output$ggplot_download <- downloadHandler(
        filename = function() {
            sprintf('%s-%s.%s', tolower(input$plot_tabs), format(Sys.time(), "%y%m%d_%H%M%S"), rv$figure_save_format())
        },
        content = function(file) {
            dpi <- rv$figure_save_dpi()
            if (input$plot_tabs == "Venn") {
                plot_func <- plot_functions[["venn"]]
            }
            else if (input$plot_tabs == "Upset") {
                plot_func <- plot_functions[["upset"]]
            }
            else if (input$plot_tabs == "FoldComparison") {
                plot_func <- plot_functions[["fold_comp"]]
            }
            else if (input$plot_tabs == "UpsetPresence") {
                plot_func <- plot_functions[["upset_qual"]]
            }
            else {
                stop(sprintf("Unknown state for input$plot_tabs: %s", input$plot_tabs))
            }
            
            ggsave(
                file, 
                plot = plot_func(),
                width = rv$figure_save_width() / dpi, 
                height = rv$figure_save_height() / dpi, 
                units = "in", 
                dpi = dpi)
        }
    )
    
    spotcheck_listen <- reactive({
        list(input$update_spotcheck, input$update_spotcheck_upset, input$update_spotcheck_upset_pres)
    })
    
    observeEvent(spotcheck_listen(), {
        if (!is.null(parent_session)) {
            
            if (input$plot_tabs == "Venn") {
                selected_rows <- input$table_display_rows_selected
            }
            else if (input$plot_tabs == "Upset") {
                selected_rows <- input$table_display_upset_rows_selected
            }
            else if (input$plot_tabs == "UpsetPresence") {
                selected_rows <- input$table_display_upset_presence_rows_selected
            }
            else {
                warning("Unknown situation, cannot spotcheck for tab: ", input$plot_tabs)
            }
            
            req(length(selected_rows) > 0)
            
            selected_ids <- output_table_reactive()[selected_rows, ]$comb_id %>% as.character()
            rv$set_selected_feature(selected_ids, module_name)
            updateTabsetPanel(session=parent_session, inputId="navbar", selected="FeatureCheck")
        }
        else {
            warning("Switching navbar requires access to parent session")
        }
    })
    
    observeEvent(input$help, {
        shinyalert(
            title = "Help: Overlap visuals",
            text = help_overlap, 
            html = TRUE
        )
    })
    
    parsed_overlap_entries <- reactive({
        
        req(input$upset_ref_comparisons != "Dev")

        parsed_ref_comps <- input$upset_ref_comparisons %>% gsub("\\.$", "", .)
        if (input$fold_split_upset) {
            parsed_ref_comps <- c(
                paste(parsed_ref_comps, "up", sep="."),
                paste(parsed_ref_comps, "down", sep=".")
            )
        }
        
        if (input$dataset1 == input$dataset2) {
            parsed_ref_comps
        }
        else {
            parsed_comp_comps <- input$upset_comp_comparisons %>% gsub("\\.$", "", .)
            if (input$fold_split_upset) {
                parsed_comp_comps <- c(
                    paste(parsed_comp_comps, "up", sep="."),
                    paste(parsed_comp_comps, "down", sep=".")
                )
            }
            parsed_combined_comps <- c(
                paste("d1", parsed_ref_comps, sep="."),
                paste("d2", parsed_comp_comps, sep=".")
            )
            parsed_combined_comps
        }
    })
    
    parsed_presence_entries <- reactive({
        
        req(input$upset_pres_levels_ref != "Dev")
        
        if (input$dataset1 == input$dataset2) {
            input$upset_pres_levels_ref
        }
        else {
            c(paste("d1", input$upset_pres_levels_ref, sep="."),
              paste("d2", input$upset_pres_levels_comp, sep="."))
        }
    })
    
    selected_id_reactive <- reactive({
        output_table_reactive()[input$table_display_rows_selected, ]$comb_id %>% as.character()
    })
    
    ref_pass_reactive <- reactive({
        parse_contrast_pass_list(rv, input, input$dataset1, input$ref_contrast, input$stat_contrast_type)
    })
    
    comp_pass_reactive <- reactive({
        parse_contrast_pass_list(rv, input, input$dataset2, input$comp_contrast, input$stat_contrast_type)
    })
    
    output_table_reactive <- reactive({
        
        shiny::validate(need(!is.null(rv$mapping_obj()), "No mapping object found, are samples mapped at the Setup page?"))
        shiny::validate(need(!is.null(rv$mapping_obj()$get_combined_dataset()), "No combined dataset found, are samples mapped at the Setup page?"))
        
        get_target_ids_from_presence <- function(presence_df, all_conditions, selected_conditions) {
            non_selected_conditions <- all_conditions %>% discard(~. %in% selected_conditions)
            presence_inintersect_df <- presence_df %>% 
                dplyr::filter_at(vars(all_of(selected_conditions)), ~.==1)
            
            if (length(non_selected_conditions) > 0) {
                presence_inintersect_notinothers_df <- presence_inintersect_df %>% 
                    dplyr::filter_at(vars(all_of(non_selected_conditions)), ~.==0)
                target_ids <- presence_inintersect_notinothers_df %>% pull(.data$id_col)
            }
            else {
                target_ids <- presence_inintersect_df %>% pull(.data$id_col)
            }
            target_ids
        }
        
        
        if (input$plot_tabs == "Venn") {
            ref_pass <- names(ref_pass_reactive())
            comp_pass <- names(comp_pass_reactive())
            
            if (input$select_target == "A&B") {
                target_ids <- union(ref_pass, comp_pass)
            }
            else if (input$select_target == "A|B") {
                target_ids <- intersect(ref_pass, comp_pass)
            }
            else if (input$select_target == "A") {
                target_ids <- setdiff(ref_pass, comp_pass)
            }
            else if (input$select_target == "B") {
                target_ids <- setdiff(comp_pass, ref_pass)
            }
            else {
                stop(sprintf("Unknown input$select_target: %s", input$select_target))
            }
        }
        else if (input$plot_tabs == "Upset") {

            get_is_element <- function(target_feature, all_features){
                is.element(all_features, target_feature)
            }
            
            contrast_features_list <- upset_plot_list()
            all_features <- contrast_features_list %>% unlist() %>% unique()

            presence_df <- lapply(contrast_features_list, get_is_element, all_features=all_features) %>% 
                map(as.integer) %>% 
                data.frame() %>%
                mutate(id_col=all_features)
                
            all_contrasts <- UpSetR::fromList(contrast_features_list) %>% colnames()
            target_ids <- get_target_ids_from_presence(presence_df, all_contrasts, input$upset_crosssec_display)
        }
        else if (input$plot_tabs == "UpsetPresence") {
            
            presence_df <- upset_presence_dataframe() %>% 
                dplyr::filter_at(vars(!matches("^comb_id$")), any_vars(. != "0")) %>%
                dplyr::rename(id_col=.data$comb_id)
            all_condition_levels <- UpSetR::fromList(presence_df) %>% colnames() %>% discard(~.=="id_col")
            
            if (!all(input$upset_crosssec_display_presence %in% colnames(presence_df))) {
                message("Headers not present, likely due to react call order")
                return()
            }
            
            target_ids <- get_target_ids_from_presence(presence_df, all_condition_levels, input$upset_crosssec_display_presence)
        }
        else {
            stop("input$plot_tabs should be either Venn or Upset, found: ", input$plot_tabs)
        }
        
        rv$mapping_obj()$get_combined_dataset(include_non_matching=TRUE) %>%
            dplyr::filter(.data$comb_id %in% target_ids)
    })
    
    upset_plot_list <- reactive({

        ref_names_list <- upset_extract_set_names_list(rv, input, input$upset_ref_comparisons, input$dataset1, input$stat_contrast_type, input$fold_split_upset)
        plot_list <- upset_get_plot_list(ref_names_list, input$upset_ref_comparisons, input$fold_split_upset)
        if (input$dataset1 != input$dataset2) {
            comp_names_list <- upset_extract_set_names_list(rv, input, input$upset_comp_comparisons, input$dataset2, input$stat_contrast_type, input$fold_split_upset)
            plot_list_comp <- upset_get_plot_list(comp_names_list, input$upset_comp_comparisons, input$fold_split_upset)
            plot_list <- c(
                plot_list %>% `names<-`(paste("d1", names(plot_list), sep=".")), 
                plot_list_comp %>% `names<-`(paste("d2", names(plot_list_comp), sep="."))
            )
        }
        plot_list
    })
    
    upset_presence_dataframe <- reactive({
        comb_data <- rv$mapping_obj()$get_combined_dataset(include_non_matching=TRUE)
        
        nbr_nas <- get_na_nbrs_uppres(rv, input, comb_data, input$upset_pres_cond_ref, input$upset_pres_levels_ref, dataset_nbr=1, target="ref")
        upset_table <- parse_na_nbrs_to_upset_table(
            nbr_nas, 
            input$dataset1, 
            rv$ddf_ref(rv, input$dataset1), 
            input$upset_pres_cond_ref,
            input$upset_pres_levels_ref,
            presence_fraction_thres=input$upset_pres_frac)

        if (input$dataset1 != input$dataset2) {
            nbr_nas_comp <- get_na_nbrs_uppres(rv, input, comb_data, input$upset_pres_cond_comp, input$upset_pres_levels_comp, dataset_nbr=2, target="comp")
            upset_table_comp <- parse_na_nbrs_to_upset_table(
                nbr_nas_comp, 
                input$dataset2, 
                rv$ddf_comp(rv, input$dataset2), 
                input$upset_pres_cond_comp,
                input$upset_pres_levels_comp,
                presence_fraction_thres=input$upset_pres_frac)
            
            ref_count <- ncol(upset_table) - 1
            comp_count <- ncol(upset_table_comp) - 1
            upset_table <- cbind(
                upset_table[, -ncol(upset_table), drop=FALSE] %>% rename_all(~paste("d1", ., sep=".")),
                upset_table_comp %>% rename_at(vars(!matches("^comb_id$")), ~paste("d2", ., sep="."))
            )
        }
        upset_table
    })
    
    upset_name_order <- reactive({
        plot_list <- upset_plot_list()
        upset_get_name_order(plot_list, input$fold_split_upset)
    })
    
    upset_metadata <- reactive({
        plot_list <- upset_plot_list()
        upset_metadata_obj <- upset_get_metadata(plot_list, input$fold_split_upset)
        if (input$dataset1 != input$dataset2) {
            if (!input$fold_split_upset) {
                metadata <- data.frame(
                    comparison = names(plot_list),
                    data_source = names(plot_list) %>% gsub("\\..*", "", .)
                )
                color_vector <- c(d1 = "navy", d2 = "orange")
            }
            else {
                metadata <- data.frame(
                    comparison = names(plot_list),
                    data_source = names(plot_list) %>% gsub("\\..*\\.", "\\.", .)
                )
                color_vector <- c(d1.up="red", d1.down="navy", d2.up="orange", d2.down="darkgreen")
            }
            upset_metadata_obj <- list(
                data = metadata,
                plots = list(list(
                    type = "matrix_rows",
                    column = "data_source",
                    colors = color_vector,
                    alpha=0.2
                ))
            )
        }
        upset_metadata_obj
    })
    
    upset_order_by <- reactive({
        if (input$upset_degree_order) {
            "degree"
        }
        else {
            "freq"
        }
    })
    
    plot_functions <- list()
    plot_functions$venn <- function() {
        venn$do_paired_expression_venn(
            ref_pass_reactive(), 
            comp_pass_reactive(), 
            title="", 
            highlight = input$select_target)
    }
    plot_functions$upset <- function() {
        plot_list <- upset_plot_list()
        name_order <- upset_name_order()
        upset_metadata_obj <- upset_metadata()
        
        shiny::validate(need(
            length(plot_list) > 1, 
            sprintf(sprintf("Number of contrasts need to be more than one, found: %s", length(plot_list)))
        ))
        
        if ("plots" %in% names(upset_metadata_obj)) {
            target_metadata <- upset_metadata_obj
        }
        else {
            target_metadata <- NULL
        }
        
        set_ordering <- get_ordered_sets(UpSetR::fromList(plot_list), order_on = upset_order_by(), name_order=name_order)
        crosssection_target_ordered <- input$upset_crosssec_display[order(match(input$upset_crosssec_display, name_order))]
        bar_coloring <- (set_ordering$string_entries == paste(crosssection_target_ordered, collapse=",")) %>% ifelse("#298ff5", "gray23")
        
        UpSetR::upset(
            UpSetR::fromList(plot_list), 
            set.metadata=target_metadata,
            order.by=upset_order_by(), 
            sets=name_order,
            keep.order=TRUE,
            text.scale=2, 
            nsets=input$upset_max_comps,
            nintersects=input$upset_max_intersects,
            main.bar.color=bar_coloring
        ) %>% ggplotify::as.ggplot()
    }
    plot_functions$fold_comp <- function() {
        ref_names_list <- lapply(input$upset_ref_comparisons, function(stat_pattern, dataset, contrast_type) {
            parse_contrast_pass_list(rv, input, dataset, stat_pattern, contrast_type) %>% names()
        }, dataset=input$dataset1, contrast_type=input$stat_contrast_type)
        
        if (input$dataset1 != input$dataset2) {
            comp_names_list <- lapply(input$upset_comp_comparisons, function(stat_pattern, dataset, contrast_type) {
                parse_contrast_pass_list(rv, input, dataset, stat_pattern, contrast_type) %>% names()
            }, dataset=input$dataset2, contrast_type=input$stat_contrast_type)
            
            plot_list <- c(ref_names_list, comp_names_list)
            names(plot_list) <- c(
                paste("d1", input$upset_ref_comparisons, sep="."),
                paste("d2", input$upset_comp_comparisons, sep=".")
            )
        }
        else {
            plot_list <- ref_names_list
            names(plot_list) <- input$upset_ref_comparisons
        }
        
        present_in_all <- Reduce(intersect, plot_list)
        
        contrast_pval_cols_ref <- map(input$upset_ref_comparisons, ~rv$statcols_ref(rv, input$dataset1, contrast_field = .)$P.Value) %>% unlist()
        contrast_fold_cols_ref <- map(input$upset_ref_comparisons, ~rv$statcols_ref(rv, input$dataset1, contrast_field = .)$logFC) %>% unlist()
        contrast_pval_cols_comp <- map(input$upset_comp_comparisons, ~rv$statcols_comp(rv, input$dataset2, contrast_field = .)$P.Value) %>% unlist()
        contrast_fold_cols_comp <- map(input$upset_comp_comparisons, ~rv$statcols_comp(rv, input$dataset2, contrast_field = .)$logFC) %>% unlist()
        
        if (input$dataset1 == input$dataset2) {
            
            long_df <- rv$mapping_obj()$get_combined_dataset(include_non_matching=TRUE) %>% 
                dplyr::filter(.data$comb_id %in% present_in_all) %>%
                mutate(
                    p_sum=rowSums(.[, contrast_pval_cols_ref, drop=FALSE]),
                    p_prod=rowSums(.[, contrast_pval_cols_ref, drop=FALSE])
                ) %>%
                arrange(.data$p_sum) %>%
                head(input$max_fold_comps) %>%
                dplyr::select(ID=.data$comb_id, p_sum=.data$p_sum, contrast_fold_cols_ref
                ) %>%
                tidyr::gather("Comparison", "Fold", -.data$ID, -.data$p_sum)
        }
        else {
            long_df <- rv$mapping_obj()$get_combined_dataset(include_non_matching=TRUE) %>% 
                dplyr::filter(.data$comb_id %in% present_in_all) %>%
                mutate(
                    p_sum=rowSums(.[, c(contrast_pval_cols_ref, contrast_pval_cols_comp), drop=FALSE]),
                    p_prod=rowSums(.[, c(contrast_pval_cols_ref, contrast_pval_cols_comp), drop=FALSE])
                ) %>%
                arrange(.data$p_sum) %>%
                head(input$max_fold_comps) %>%
                dplyr::select(ID=.data$comb_id, p_sum=.data$p_sum, contrast_fold_cols_ref, contrast_fold_cols_comp
                ) %>%
                tidyr::gather("Comparison", "Fold", -.data$ID, -.data$p_sum)
        }
        
        plt <- ggplot(long_df, aes(x=reorder(.data$ID, .data$p_sum), y=.data$Fold)) + 
            theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
            geom_boxplot() +
            geom_point(aes(color=.data$Comparison)) + 
            xlab("") +
            ggtitle(sprintf("%s out of %s features present in all shown", 
                            min(input$max_fold_comps, length(present_in_all)), 
                            length(present_in_all)
            ))
        plt
    }
    plot_functions$upset_qual <- function() {
        upset_table <- upset_presence_dataframe()
        metadata <- NULL
        
        if (input$dataset1 != input$dataset2) {
            
            ref_count <- colnames(upset_table) %>% keep(grepl("^d1\\.", .)) %>% length()
            comp_count <- colnames(upset_table) %>% keep(grepl("^d2\\.", .)) %>% length()
            
            metadata <- list(
                data = data.frame(
                    source=colnames(upset_table)[-ncol(upset_table)],
                    dataset=c(
                        rep("d1", ref_count),
                        rep("d2", comp_count)
                    )
                ),
                plots = list(list(
                    type = "matrix_rows",
                    column = "dataset",
                    colors = c(d1="navy", d2="red"),
                    alpha=0.2
                ))
            )
        }
        
        name_order <- upset_table[, -ncol(upset_table)] %>% colnames()
        set_ordering <- get_ordered_sets(upset_table[, -ncol(upset_table)], order_on = upset_order_by(), name_order=name_order)
        bar_coloring <- (set_ordering$string_entries == paste(input$upset_crosssec_display_presence, collapse=",")) %>% ifelse("#298ff5", "gray23")
        
        UpSetR::upset(
            upset_table[, -ncol(upset_table)], 
            set.metadata=metadata,
            order.by=upset_order_by(), 
            sets=name_order,
            keep.order=TRUE,
            text.scale=2, 
            nsets=input$upset_max_comps,
            nintersects=input$upset_max_intersects,
            main.bar.color=bar_coloring
        ) %>% ggplotify::as.ggplot()
    }
    
    output$upset_presence <- renderPlot({
        plot_functions$upset_qual()
    })
    
    output$upset <- renderPlot({
        plot_functions$upset()
    }, height = 800)
    
    output$fold_comp <- renderPlot({
        plot_functions$fold_comp()
    })
    
    output$fold_fractions_among_sig <- renderPlot({
        
        shiny::validate(need(!is.null(rv$mapping_obj()), "No loaded data found, is everything set up at the Setup page?"))
        
        combined_dataset <- rv$mapping_obj()$get_combined_dataset(full_entries=FALSE, include_non_matching=FALSE)
        plot_df <- data.frame(
            ref_sig = combined_dataset[[rv$statcols_ref(rv, input$dataset1, input$ref_contrast)$P.Value]],
            ref_fold = combined_dataset[[rv$statcols_ref(rv, input$dataset1, input$ref_contrast)$logFC]],
            comp_sig = combined_dataset[[rv$statcols_comp(rv, input$dataset2, input$comp_contrast)$P.Value]],
            comp_fold = combined_dataset[[rv$statcols_comp(rv, input$dataset2, input$comp_contrast)$logFC]]
        ) %>% 
            mutate(highest_p=pmax(.data$ref_sig, .data$comp_sig)) %>% 
            arrange(.data$highest_p) %>%
            mutate(is_contra=sign(.data$ref_fold) != sign(.data$comp_fold)) %>%
            mutate(tot_contra=cumsum(.data$is_contra), tot_same=cumsum(!.data$is_contra)) %>%
            mutate(cum_frac_contra=.data$tot_same/(.data$tot_same+.data$tot_contra))
        
        plt_cumfrac_over_logp <- ggplot(plot_df, aes(x=log10(.data$highest_p), y=.data$cum_frac_contra)) + geom_line()
        plt_cumfrac_over_p <- ggplot(plot_df, aes(x=.data$highest_p, y=.data$cum_frac_contra)) + geom_line()
        
        ggarrange(plt_cumfrac_over_p, plt_cumfrac_over_logp, ncol=1, nrow=2) %>% 
            ggpubr::annotate_figure(., top="Fraction same fold for different p-value thresholds")
    })
    
    output$table_display <- output$table_display_upset <- output$table_display_upset_presence <- DT::renderDataTable({
        req(output_table_reactive())
        rv$dt_parsed_data(rv, output_table_reactive())
    })
    
    output$venn <- renderPlot({
        plot_functions$venn()
    })
    
    observeEvent({
        rv$filedata_1()
        rv$filedata_2()}, {
        choices <- get_dataset_choices(rv)
        updateSelectInput(session, "dataset1", choices=choices, selected=choices[1])
        updateSelectInput(session, "dataset2", choices=choices, selected=choices[1])
    }, ignoreInit=TRUE, ignoreNULL=FALSE)

    observeEvent(input$upset_pres_cond_ref, {
        req(rv$ddf_ref(rv, input$dataset1))
        choices <- rv$ddf_ref(rv, input$dataset1)[[input$upset_pres_cond_ref]] %>% unique() 
        updateSelectInput(session, "upset_pres_levels_ref", choices=choices, selected=choices)
    })
    
    observeEvent(input$upset_pres_cond_comp, {
        req(rv$ddf_comp(rv, input$dataset2))
        choices <- rv$ddf_comp(rv, input$dataset2)[[input$upset_pres_cond_comp]] %>% unique() 
        updateSelectInput(session, "upset_pres_levels_comp", choices=choices, selected=choices)
    })
    
    set_if_new <- function(prev_val, new_values, new_val_selected) {
        
        if (is.null(prev_val)) new_val_selected
        else if (all(prev_val %in% new_values)) prev_val
        else new_val_selected
    }
    
    observeEvent({
        input$upset_ref_comparisons
        input$upset_comp_comparisons
        input$fold_split_upset
        input$dataset1
        input$dataset2
        }, {
        updateSelectInput(session, "upset_crosssec_display", choices=parsed_overlap_entries(), 
                          selected = set_if_new(input$upset_crosssec_display, parsed_overlap_entries(), parsed_overlap_entries()))
    })
    
    observeEvent(parsed_presence_entries(), {
        updateSelectInput(session, "upset_crosssec_display_presence", choices=parsed_presence_entries(), 
                          selected = set_if_new(input$upset_crosssec_display_presence, parsed_presence_entries(), parsed_presence_entries()))
    })
    
    observeEvent({
        rv$selected_cols_obj() 
        input$dataset1 
        input$dataset2}, {
            req(rv$filename_1())
            req(rv$ddf_ref(rv, input$dataset1))
            req(rv$ddf_comp(rv, input$dataset2))
            
            choices_1 <- rv$selected_cols_obj()[[input$dataset1]]$statpatterns
            updateSelectInput(session, "ref_contrast", choices=choices_1, selected=set_if_new(input$ref_contrast, choices_1, choices_1[1]))
            updateSelectInput(session, "upset_ref_comparisons", choices=choices_1, selected=set_if_new(input$upset_ref_comparisons, choices_1, choices_1))
            
            choices_2 <- rv$selected_cols_obj()[[input$dataset2]]$statpatterns
            updateSelectInput(session, "comp_contrast", choices=choices_2, selected=set_if_new(input$comp_contrast, choices_2, choices_2[1]))
            updateSelectInput(session, "upset_comp_comparisons", choices=choices_2, selected=set_if_new(input$upset_comp_comparisons, choices_2, choices_2))
            
            ref_cond_choices <- c("None", rv$ddf_cols_ref(rv, input$dataset1))
            updateSelectInput(session, "upset_pres_cond_ref", choices = ref_cond_choices, selected=set_if_new(input$upset_pres_cond_ref, ref_cond_choices, ref_cond_choices[2]))
            # updateSelectInput(session, "upset_pres_cond_ref", choices = ref_cond_choices, selected=ref_cond_choices[2])
            
            comp_cond_choices <- c("None", rv$ddf_cols_comp(rv, input$dataset2))
            updateSelectInput(session, "upset_pres_cond_comp", choices = comp_cond_choices, selected=set_if_new(input$upset_pres_cond_ref, ref_cond_choices, ref_cond_choices[2]))
            # updateSelectInput(session, "upset_pres_cond_comp", choices = comp_cond_choices, selected=comp_cond_choices[2])
        })
}

