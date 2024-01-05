#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { dm, fa } cache_map_t;
typedef enum { uc, sc } cache_org_t;
typedef enum { instruction, data } access_t;

typedef struct {
    uint32_t address;
    access_t accesstype;
} mem_access_t;

typedef struct {
    uint64_t accesses;
    uint64_t hits;
} cache_stat_t;

uint32_t cache_size;
uint32_t block_size = 64;
cache_map_t cache_mapping;
cache_org_t cache_org;

cache_stat_t cache_statistics;

typedef struct {
    int valid;
    uint32_t tag;
    uint32_t timestamp; // For FIFO
} cache_line_t;

// Cache arrays
cache_line_t* unified_cache = NULL;

cache_line_t* instruction_cache = NULL;
cache_line_t* data_cache = NULL;

// Current time (for FIFO)
uint32_t current_time;

/* Reads a memory access from the trace file and returns
 * 1) access type (instruction or data access
 * 2) memory address
 */
mem_access_t read_transaction(FILE* ptr_file) {
    char type;
    mem_access_t access;

    if (fscanf(ptr_file, "%c %x\n", &type, &access.address) == 2) {
        if (type != 'I' && type != 'D') {
            printf("Unknown access type\n");
            exit(0);
        }
        access.accesstype = (type == 'I') ? instruction : data;
        return access;
    }

    /* If there are no more entries in the file,
     * return an address 0 that will terminate the infinite loop in main
     */
    access.address = 0;
    return access;
}

// Cache initialization function
void initialize_cache() {
    // Calculate the number of cache lines based on cache size and block size
    uint32_t num_cache_lines = cache_size / block_size;

    // Allocate space for the cache
    if (cache_org == sc) {
        instruction_cache = (cache_line_t *)malloc(sizeof(cache_line_t) * num_cache_lines);
        data_cache = (cache_line_t *)malloc(sizeof(cache_line_t) * num_cache_lines);
    } else if (cache_org == uc) {
        unified_cache = (cache_line_t *)malloc(sizeof(cache_line_t) * num_cache_lines);
    }
}

int get_cache_size(const cache_line_t* cache) {
    int index = 0;
    for (int i = 0; i < cache_size; i++) {
        if (cache[i].valid == 1) {
            index++;
        }
    }
    return index;
}

// Function to insert data into the cache
void insert_into_cache(cache_line_t* cache, uint32_t index, uint32_t tag) {
    current_time++; // Increment current time

    // If the cache line is already valid, just update the tag and timestamp
    if (cache[index].valid) {
        cache[index].tag = tag;
        cache[index].timestamp = current_time; // Update timestamp
    } else {
        // If the cache line is not valid, check if the cache is full
        int cache_full = 1;
        for (uint32_t i = 0; i < (cache_size / block_size); i++) {
            if (!cache[i].valid) {
                cache_full = 0;
                break;
            }
        }

        // If the cache is full, find the oldest block and replace it
        if (cache_full) {
            uint32_t oldest_index = 0;
            for (uint32_t i = 0; i < (cache_size / block_size); i++) {
                if (cache[i].timestamp < cache[oldest_index].timestamp) {
                    oldest_index = i;
                }
            }
            index = oldest_index; // Replace the oldest block
        }

        // Insert the new data into the cache
        cache[index].valid = 1;
        cache[index].tag = tag;
        cache[index].timestamp = current_time; // Set timestamp
    }
}


// Cache lookup function
int cache_lookup(cache_line_t* cache, uint32_t address) {
    // Calculate the cache index and tag for the given address
    uint32_t index; // For direct-mapped, not used
    uint32_t tag;

    int len = get_cache_size(cache);
    printf("Cache size before: %d\n", len);

    if (cache_mapping == dm) {
        index = (address / block_size) % (cache_size / block_size);
        tag = address / (block_size * (cache_size / block_size));
    } else if (cache_mapping == fa) {
        index = 0; // Not used for fully associative
        tag = address / block_size;
    }

    // Perform cache lookup based on cache mapping type
    if (cache_mapping == dm) {
        if (cache[index].valid && cache[index].tag == tag) {
            return 1; // Cache hit
        } else {
            // Cache miss, insert the data into the cache
            insert_into_cache(cache, index, tag);
            return 0; // Cache miss
        }
    } else if (cache_mapping == fa) {
        // Search for the data in the cache
        for (uint32_t i = 0; i < (cache_size / block_size); i++) {
            if (cache[i].valid && cache[i].tag == tag) {
                return 1; // Cache hit
            }
        }

        // Cache miss, find the first invalid or oldest block to replace
        uint32_t replace_index = 0;
        for (uint32_t i = 0; i < (cache_size / block_size); i++) {
            if (!cache[i].valid) {
                replace_index = i;
                break;
            } else if (cache[i].timestamp < cache[replace_index].timestamp) {
                replace_index = i;
            }
        }
        insert_into_cache(cache, replace_index, tag);
        return 0; // Cache miss
    }

    return 0; // Cache miss (default)
}



int main(int argc, char** argv) {
    // Reset statistics:
    memset(&cache_statistics, 0, sizeof(cache_stat_t));

    /* Read command-line parameters and initialize:
     * cache_size, cache_mapping and cache_org variables
     */
    if (argc != 4) { /* argc should be 2 for correct execution */
        printf(
                "Usage: ./cache_sim [cache size: 128-4096] [cache mapping: dm|fa] "
                "[cache organization: uc|sc]\n");
        exit(0);

        // Default values, if no command line parameters are given (for testing)
        // cache_size = 4096;
        // cache_mapping = dm;
        // cache_org = uc;
    } else {
        /* argv[0] is program name, parameters start with argv[1] */

        /* Set cache size */
        cache_size = atoi(argv[1]);

        /* Set Cache Mapping */
        if (strcmp(argv[2], "dm") == 0) {
            cache_mapping = dm;
        } else if (strcmp(argv[2], "fa") == 0) {
            cache_mapping = fa;
        } else {
            printf("Unknown cache mapping\n");
            exit(0);
        }

        /* Set Cache Organization */
        if (strcmp(argv[3], "uc") == 0) {
            cache_org = uc;
        } else if (strcmp(argv[3], "sc") == 0) {
            cache_org = sc;
        } else {
            printf("Unknown cache organization\n");
            exit(0);
        }
    }

    // Initialize the cache
    initialize_cache();
    current_time = 0;

    /* Open the file mem_trace.txt to read memory accesses */
    FILE* ptr_file;
    ptr_file = fopen("mem_trace.txt", "r");
    if (!ptr_file) {
        printf("Unable to open the trace file\n");
        exit(1);
    }

    /* Loop until whole trace file has been read */
    mem_access_t access;
    while (1) {
        access = read_transaction(ptr_file);
        // If no transactions left, break out of loop
        if (access.address == 0) break;
        printf("%d %x\n", access.accesstype, access.address);

        int cache_hit = 0;

        if (cache_org == sc) {
            if (access.accesstype == instruction) {
                cache_hit = cache_lookup(instruction_cache, access.address);
            } else if (access.accesstype == data) {
                cache_hit = cache_lookup(data_cache, access.address);
            }
        } else if (cache_org == uc) {
            cache_hit = cache_lookup(unified_cache, access.address);
        }

        cache_statistics.accesses++;
        if (cache_hit) {
            cache_statistics.hits++;
        }
    }

    /* Print the statistics */
    printf("\nCache Statistics\n");
    printf("-----------------\n\n");
    printf("Accesses: %ld\n", cache_statistics.accesses);
    printf("Hits:     %ld\n", cache_statistics.hits);
    printf("Hit Rate: %.4f\n",
           (double)cache_statistics.hits / cache_statistics.accesses);

    /* Close the trace file */
    fclose(ptr_file);

    free(unified_cache);
    free(instruction_cache);
    free(data_cache);

    return 0;
}
