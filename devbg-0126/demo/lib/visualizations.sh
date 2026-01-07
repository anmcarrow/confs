#!/bin/bash

# Terminal Visualization Functions
# Colorful text-based charts for demo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Bar colors array
BAR_COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN")

# Spinner frames for animated loading
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_PID=""

# Start animated spinner in background
# Usage: start_spinner "Loading message"
start_spinner() {
    local message="${1:-Processing}"
    
    # Hide cursor
    tput civis 2>/dev/null
    
    # Spinner loop
    {
        local i=0
        while true; do
            printf "\r${CYAN}${SPINNER_FRAMES[$i]}${RESET} ${WHITE}%s${RESET}" "$message"
            i=$(( (i + 1) % ${#SPINNER_FRAMES[@]} ))
            sleep 0.1
        done
    } &
    
    SPINNER_PID=$!
}

# Stop spinner
stop_spinner() {
    if [ -n "$SPINNER_PID" ]; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
        SPINNER_PID=""
        printf "\r\033[K"  # Clear line
        tput cnorm 2>/dev/null  # Show cursor
    fi
}

# Progress spinner with completion
# Usage: spinner_with_progress "Message" duration_seconds
spinner_with_progress() {
    local message=$1
    local duration=${2:-3}
    local start_time=$(date +%s)
    local i=0
    
    tput civis 2>/dev/null
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -ge $duration ]; then
            printf "\r${GREEN}✓${RESET} ${WHITE}%s${RESET} ${DIM}(completed)${RESET}\n" "$message"
            break
        fi
        
        local percent=$((elapsed * 100 / duration))
        printf "\r${CYAN}${SPINNER_FRAMES[$i]}${RESET} ${WHITE}%s${RESET} ${DIM}%d%%${RESET}" "$message" "$percent"
        
        i=$(( (i + 1) % ${#SPINNER_FRAMES[@]} ))
        sleep 0.1
    done
    
    tput cnorm 2>/dev/null
}

# Generate a horizontal bar chart
# Usage: horizontal_bar_chart "Label" value max_value color
horizontal_bar_chart() {
    local label=$1
    local value=$2
    local max_value=$3
    local color=$4
    
    local bar_length=$((value * 50 / max_value))
    local bar=$(printf '█%.0s' $(seq 1 $bar_length))
    
    printf "${WHITE}%-20s${RESET} ${color}%s${RESET} ${CYAN}%3d%%${RESET}\n" "$label" "$bar" "$value"
}

# Show requirements complexity chart
show_requirements_chart() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}📊 Requirements Analysis Metrics${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    sleep 0.5
    horizontal_bar_chart "Functional Req" 85 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Non-Functional" 72 100 "$BLUE"
    sleep 0.3
    horizontal_bar_chart "Business Value" 93 100 "$MAGENTA"
    sleep 0.3
    horizontal_bar_chart "Feasibility" 88 100 "$YELLOW"
    sleep 0.3
    horizontal_bar_chart "Completeness" 91 100 "$CYAN"
    
    echo ""
    echo -e "${GREEN}✓${RESET} Overall Score: ${WHITE}85.8%${RESET} - Ready for Architecture Phase"
    echo ""
}

# Show architecture components chart
show_architecture_chart() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}🏗️  Architecture Component Distribution${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    sleep 0.5
    horizontal_bar_chart "API Layer" 30 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Business Logic" 25 100 "$BLUE"
    sleep 0.3
    horizontal_bar_chart "Data Layer" 20 100 "$MAGENTA"
    sleep 0.3
    horizontal_bar_chart "Auth & Security" 15 100 "$YELLOW"
    sleep 0.3
    horizontal_bar_chart "Error Handling" 10 100 "$CYAN"
    
    echo ""
    echo -e "${GREEN}✓${RESET} Architecture Decisions: ${WHITE}5 ADRs${RESET} documented"
    echo ""
}

# Show code metrics chart
show_code_metrics_chart() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}💻 Code Generation Metrics${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    sleep 0.5
    horizontal_bar_chart "Code Quality" 92 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Documentation" 88 100 "$BLUE"
    sleep 0.3
    horizontal_bar_chart "Best Practices" 95 100 "$MAGENTA"
    sleep 0.3
    horizontal_bar_chart "Error Handling" 87 100 "$YELLOW"
    sleep 0.3
    horizontal_bar_chart "Maintainability" 90 100 "$CYAN"
    
    echo ""
    echo -e "${GREEN}✓${RESET} Generated: ${WHITE}~250 lines${RESET} of production-ready code"
    echo ""
}

# Show test coverage chart
show_test_coverage_chart() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}🧪 Test Coverage Metrics${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    sleep 0.5
    horizontal_bar_chart "Unit Tests" 95 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Integration Tests" 88 100 "$BLUE"
    sleep 0.3
    horizontal_bar_chart "Edge Cases" 82 100 "$MAGENTA"
    sleep 0.3
    horizontal_bar_chart "Error Scenarios" 90 100 "$YELLOW"
    sleep 0.3
    horizontal_bar_chart "API Endpoints" 100 100 "$CYAN"
    
    echo ""
    echo -e "${GREEN}✓${RESET} Overall Coverage: ${WHITE}91%${RESET} - Production Ready"
    echo ""
}

# Show deployment success chart
show_deployment_chart() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}🚀 Deployment Pipeline Status${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    sleep 0.5
    horizontal_bar_chart "Infrastructure" 100 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Database Setup" 100 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "API Deployment" 100 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Health Checks" 100 100 "$GREEN"
    sleep 0.3
    horizontal_bar_chart "Endpoint Tests" 100 100 "$GREEN"
    
    echo ""
    echo -e "${GREEN}✓${RESET} Deployment Status: ${WHITE}SUCCESS${RESET} - All systems operational"
    echo ""
}

# Show animated timeline (old version - keep for compatibility)
show_timeline_old() {
    local phase=$1
    local total_phases=5
    
    echo ""
    echo -e "${CYAN}Pipeline Progress${RESET}"
    echo -n "["
    
    for i in $(seq 1 $total_phases); do
        if [ $i -lt $phase ]; then
            echo -n -e "${GREEN}●${RESET}"
        elif [ $i -eq $phase ]; then
            echo -n -e "${YELLOW}●${RESET}"
        else
            echo -n -e "${WHITE}○${RESET}"
        fi
        
        if [ $i -lt $total_phases ]; then
            echo -n "━"
        fi
    done
    
    echo "]"
    echo -e "${WHITE}Phase $phase of $total_phases${RESET}"
    echo ""
}

# Horizontal timeline showing all 5 phases (new enhanced version)
# Usage: show_timeline current_phase
show_timeline() {
    local current_phase=${1:-1}
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    # Phase names
    local phases=("REQUIREMENTS" "ARCHITECTURE" "CODE" "TESTING" "DEPLOY")
    
    # Build the timeline
    printf "  "
    for i in {1..5}; do
        if [ $i -lt $current_phase ]; then
            # Completed phase - green checkmark
            printf "${GREEN}[✓ %-12s]${RESET}" "${phases[$((i-1))]}"
        elif [ $i -eq $current_phase ]; then
            # Current phase - yellow with arrow
            printf "${YELLOW}[▶ %-12s]${RESET}" "${phases[$((i-1))]}"
        else
            # Future phase - dim
            printf "${DIM}[  %-12s]${RESET}" "${phases[$((i-1))]}"
        fi
        
        # Add connector except after last phase
        if [ $i -lt 5 ]; then
            if [ $i -lt $current_phase ]; then
                printf "${GREEN}━${RESET}"
            else
                printf "${DIM}━${RESET}"
            fi
        fi
    done
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# Phase completion badge
# Usage: show_phase_badge phase_number "PHASE NAME"
show_phase_badge() {
    local phase_num=$1
    local phase_name=$2
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${YELLOW}Phase $phase_num:${RESET} ${BOLD}${WHITE}$phase_name${RESET}$(printf '%*s' $((45 - ${#phase_name})) '')${CYAN}║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# Live code streaming with syntax highlighting
# Usage: stream_code_file file_path [delay_ms]
stream_code_file() {
    local file_path=$1
    local delay=${2:-0.02}  # Default 20ms per line
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}File not found: $file_path${RESET}"
        return 1
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}${BOLD}📄 Generated Code: $(basename "$file_path")${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    
    local line_num=1
    while IFS= read -r line || [ -n "$line" ]; do
        # Simple syntax highlighting for Python using printf with color variables
        local output_line="$line"
        
        # Apply colors inline with printf/echo
        printf "%b%4d%b │ %s\n" "$DIM" "$line_num" "$RESET" "$output_line"
        
        line_num=$((line_num + 1))
        sleep "$delay"
    done < "$file_path"
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}✓${RESET} ${WHITE}Generated $(wc -l < "$file_path") lines of code${RESET}"
    echo ""
}

# Stream code snippet (first N lines) - simplified version for reliability
# Usage: stream_code_preview file_path max_lines
stream_code_preview() {
    local file_path=$1
    local max_lines=${2:-20}
    local delay=0.03
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}File not found: $file_path${RESET}"
        return 1
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}${BOLD}📄 Preview: $(basename "$file_path")${RESET} ${DIM}(first $max_lines lines)${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    
    local line_num=1
    while IFS= read -r line && [ $line_num -le $max_lines ]; do
        # Highlight specific patterns we care about
        local display_line="$line"
        
        # Color decorators
        if [[ "$line" =~ ^[[:space:]]*@ ]]; then
            display_line="${YELLOW}${line}${RESET}"
        # Color comments
        elif [[ "$line" =~ ^[[:space:]]*# ]]; then
            display_line="${DIM}${line}${RESET}"
        # Color function/class definitions
        elif [[ "$line" =~ ^[[:space:]]*(def|class)[[:space:]] ]]; then
            display_line="${MAGENTA}${line}${RESET}"
        # Color imports
        elif [[ "$line" =~ ^[[:space:]]*(import|from)[[:space:]] ]]; then
            display_line="${BLUE}${line}${RESET}"
        fi
        
        printf "%b%4d%b │ %b\n" "$DIM" "$line_num" "$RESET" "$display_line"
        
        line_num=$((line_num + 1))
        sleep "$delay"
    done < "$file_path"
    
    local total_lines=$(wc -l < "$file_path")
    if [ $total_lines -gt $max_lines ]; then
        echo -e "${DIM}     │ ... ($((total_lines - max_lines)) more lines)${RESET}"
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# Show sparkline (simple line chart)
show_sparkline() {
    local label=$1
    shift
    local values=("$@")
    
    echo -n -e "${WHITE}$label${RESET}: "
    
    for val in "${values[@]}"; do
        case $val in
            [0-2]*)  echo -n "▁" ;;
            [3-4]*)  echo -n "▂" ;;
            [5-6]*)  echo -n "▄" ;;
            [7-8]*)  echo -n "▆" ;;
            [9]*)    echo -n "█" ;;
            *)       echo -n "▁" ;;
        esac
    done
    echo ""
}

# Show phase summary with metrics
show_phase_summary() {
    local phase_name=$1
    local duration=$2
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}📈 $phase_name - Complete${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${GREEN}✓${RESET} Duration: ${WHITE}${duration}s${RESET}"
    echo -e "  ${GREEN}✓${RESET} Status: ${GREEN}SUCCESS${RESET}"
    echo -e "  ${GREEN}✓${RESET} AI Confidence: ${WHITE}95%${RESET}"
    echo ""
    
    # Random sparkline for "AI processing intensity"
    show_sparkline "AI Processing" 2 4 6 8 9 8 6 5 3 2
    show_sparkline "Quality Score" 7 7 8 8 9 9 9 8 8 9
    
    echo ""
}

# Export functions
export -f horizontal_bar_chart
export -f start_spinner
export -f stop_spinner
export -f spinner_with_progress
export -f show_timeline
export -f show_timeline_old
export -f show_phase_badge
export -f stream_code_file
export -f stream_code_preview
export -f show_requirements_chart
export -f show_architecture_chart
export -f show_code_metrics_chart
export -f show_test_coverage_chart
export -f show_deployment_chart
export -f show_sparkline
export -f show_phase_summary
