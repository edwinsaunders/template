# ---- Project settings ----
NAME       := $(notdir $(CURDIR)) 
SRC_DIR    := src
BUILD_DIR  := build
OBJ_DIR    := $(BUILD_DIR)/obj
BIN_DIR    := $(BUILD_DIR)/bin
TARGET     := $(BIN_DIR)/$(NAME)

CC         := cc
STD        := -std=c23
WARN       := -Wall -Wextra -Wpedantic
CPPFLAGS   := -I$(SRC_DIR)
CFLAGS     := $(STD) $(WARN)
LDFLAGS    :=
LDLIBS     :=

# ---- Build modes ----
# Default: debug (no optimization, symbols)
MODE ?= debug
ifeq ($(MODE),release)
  CFLAGS += -O2 -DNDEBUG
else
  CFLAGS += -O0 -g
endif

# ---- Source discovery (recursive) ----
# Works on GNU make. Finds all .c under src/.
SRCS := $(shell find $(SRC_DIR) -type f -name '*.c')
OBJS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))
DEPS := $(OBJS:.o=.d)

# ---- Top-level targets ----
.PHONY: all release debug run clean print-vars
all: $(TARGET)

release:
	$(MAKE) MODE=release

debug:
	$(MAKE) MODE=debug

run: $(TARGET)
	./$(TARGET)

# ---- Link ----
$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@

# ---- Compile (+ auto-deps) ----
# -MMD -MP generates .d files for header dependencies
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

# ---- Include generated dependency files ----
-include $(DEPS)

# ---- Cleanup ----
clean:
	rm -rf $(BUILD_DIR)

print-vars:
	@echo "SRCS=$(SRCS)"
	@echo "OBJS=$(OBJS)"
	@echo "MODE=$(MODE)"
