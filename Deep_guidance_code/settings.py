"""
    All settings relating to D4PG are contained in this file.
    This file is copied on each run and placed in the Tensorboard directory
    so that all settings are preserved for future reference.

    Notes:


"""

class Settings:

    #%%
    ########################
    ##### Run Settings #####
    ########################

    RUN_NAME               = 'noaccelPenalty_nowrap_Velocity0_Attitude5_Position12p5'
    RESUME_TRAINING        = False # If True, main.py must be run from a previous run's 'code' folder.
    ENVIRONMENT            = 'combined' # uncomment for regular training
    #ENVIRONMENT            = 'fixedICs' # uncomment this option for testing what would have occurred from given initial conditions (also set RESUME_TRAINING to True)
    AGENT                  = '' # '' for Task 1, '_runway' for runway experiment
    RECORD_VIDEO           = True
    VIDEO_RECORD_FREQUENCY = 20 # Multiples of "CHECK_GREEDY_PERFORMANCE_EVERY_NUM_EPISODES"
    NOISELESS_AT_TEST_TIME = True # Whether or not to test without action noise (Keep at True unless debugging)
    LEARN_FROM_PIXELS      = False # False = learn from state (fully observed); True = learn from pixels (partially observed)
    USE_GPU_WHEN_AVAILABLE = True # As of Nov 19, 2018, it appears better to use CPU. Re-evaluate again later
    MAX_WALLTIME           = 60*60*24*5 - 30*60 # [s] max walltime before triggering an end-program
    


    #%%
    #############################
    ##### Training Settings #####
    #############################

    # Hyperparameters
    NUMBER_OF_ACTORS        = 10 # ideal number of agents it seems
    NUMBER_OF_EPISODES      = 1e10 # that each agent will perform
    MAX_TRAINING_ITERATIONS = 1e10 # of neural networks
    ACTOR_LEARNING_RATE     = 0.0001
    CRITIC_LEARNING_RATE    = 0.0001
    TARGET_NETWORK_TAU      = 0.001
    NUMBER_OF_BINS          = 51 # Also known as the number of atoms
    L2_REGULARIZATION       = False # optional for training the critic
    L2_REG_PARAMETER        = 1e-6

    # Periodic events
    UPDATE_TARGET_NETWORKS_EVERY_NUM_ITERATIONS       = 1
    UPDATE_ACTORS_EVERY_NUM_EPISODES                  = 1
    CHECK_GREEDY_PERFORMANCE_EVERY_NUM_EPISODES       = 5
    LOG_TRAINING_PERFORMANCE_EVERY_NUM_ITERATIONS     = 100
    DISPLAY_TRAINING_PERFORMANCE_EVERY_NUM_ITERATIONS = 50000
    DISPLAY_ACTOR_PERFORMANCE_EVERY_NUM_EPISODES      = 2500

    # Buffer settings
    PRIORITY_REPLAY_BUFFER = False
    PRIORITY_ALPHA         = 0.6            # Controls the randomness vs prioritisation of the prioritised sampling (0.0 = Uniform sampling, 1.0 = Greedy prioritisation)
    PRIORITY_BETA_START    = 0.4       # Starting value of beta - controls to what degree IS weights influence the gradient updates to correct for the bias introduced by priority sampling (0 - no correction, 1 - full correction)
    PRIORITY_BETA_END      = 1.0         # Beta will be linearly annealed from its start value to this value throughout training
    PRIORITY_EPSILON       = 0.00001      # Small value to be added to updated priorities to ensure no sample has a probability of 0 of being chosen
    DUMP_PRIORITY_REPLAY_BUFFER_EVER_NUM_ITERATIONS = 200 # Check if the prioritized replay buffer is overfulled every ## iterations. If so, dump the excess data

    REPLAY_BUFFER_SIZE                    = 1000000
    REPLAY_BUFFER_START_TRAINING_FULLNESS = 0 # how full the buffer should be before training begins
    MINI_BATCH_SIZE                       = 256

    # Exploration noise
    UNIFORM_OR_GAUSSIAN_NOISE = False # True -> Uniform; False -> Gaussian
    if UNIFORM_OR_GAUSSIAN_NOISE:
        NOISE_SCALE           = 1 # 1 is best for uniform -> noise scaled to the action range
    else:
        NOISE_SCALE           = 1/3 # standard deviation = 1/3 the action range. Therefore a 3-sigma action will cause full exploration in the worst case scenario
    NOISE_SCALE_DECAY         = 1#0.999986137152479 # 0.999986137152479 for 50k half-life # 0.9999 for 7k half-life # 1 means the noise does not decay during training

#%%
    ####################################
    ##### Model Structure Settings #####
    ####################################

    # Whether or not to learn from pixels (defined above)
    if LEARN_FROM_PIXELS:
        # Define the properties of the convolutional layer in a list. Each dict in the list is one layer
        # 'filters' gives the number of filters to be used
        # 'kernel_size' gives the dimensions of the filter
        # 'strides' gives the number of pixels that the filter skips while colvolving
        CONVOLUTIONAL_LAYERS =  [{'filters': 32, 'kernel_size': [8, 8], 'strides': [4, 4]},
                                 {'filters': 64, 'kernel_size': [4, 4], 'strides': [2, 2]},
                                 {'filters': 64, 'kernel_size': [3, 3], 'strides': [1, 1]}]


    # Fully connected layers follow the (optional) convolutional layers
    ACTOR_HIDDEN_LAYERS  = [400, 300] # number of hidden neurons in each layer
    CRITIC_HIDDEN_LAYERS = [400, 300] # number of hidden neurons in each layer


    #%%
    ##############################
    #### Environment Settings ####
    ##############################

    environment_file = __import__('environment_' + ENVIRONMENT)
    # if ENVIRONMENT == 'gym':
    #     env = environment_file.Environment('Temporary environment', 0, CHECK_GREEDY_PERFORMANCE_EVERY_NUM_EPISODES, VIDEO_RECORD_FREQUENCY, MODEL_SAVE_DIRECTORY) # Additional parameters needed for gym
    # else:
    env = environment_file.Environment()
        
    OBSERVATION_SIZE                 = env.OBSERVATION_SIZE + env.AUGMENT_STATE_WITH_ACTION_LENGTH*env.ACTION_SIZE # augmenting the state with past actions and states
    UPPER_STATE_BOUND                = env.UPPER_STATE_BOUND
    LOWER_STATE_BOUND                = env.LOWER_STATE_BOUND
    ACTION_SIZE                      = env.ACTION_SIZE
    LOWER_ACTION_BOUND               = env.LOWER_ACTION_BOUND
    UPPER_ACTION_BOUND               = env.UPPER_ACTION_BOUND
    NORMALIZE_STATE                  = env.NORMALIZE_STATE # Normalize state on each timestep to avoid vanishing gradients
    IRRELEVANT_STATES                = env.IRRELEVANT_STATES
    MIN_V                            = env.MIN_V
    MAX_V                            = env.MAX_V
    DISCOUNT_FACTOR                  = env.DISCOUNT_FACTOR
    N_STEP_RETURN                    = env.N_STEP_RETURN
    TIMESTEP                         = env.TIMESTEP
    MAX_NUMBER_OF_TIMESTEPS          = env.MAX_NUMBER_OF_TIMESTEPS # per episode
    TOTAL_STATE_SIZE                 = env.TOTAL_STATE_SIZE
    AUGMENT_STATE_WITH_ACTION_LENGTH = env.AUGMENT_STATE_WITH_ACTION_LENGTH
    VELOCITY_LIMIT                   = env.VELOCITY_LIMIT  
    ACTIONS_IN_INERTIAL              = env.ACTIONS_IN_INERTIAL
    
    # Delete the test environment
    del env

    ACTION_RANGE     = UPPER_ACTION_BOUND - LOWER_ACTION_BOUND # range for each action
    STATE_MEAN       = (LOWER_STATE_BOUND + UPPER_STATE_BOUND)/2.
    STATE_HALF_RANGE = (UPPER_STATE_BOUND - LOWER_STATE_BOUND)/2.

    RANDOM_SEED            = 13


    #%%
    #########################
    ##### Save Settings #####
    #########################    
    if RESUME_TRAINING:
        MODEL_SAVE_DIRECTORY             = '../' # up one folder
    else:
        MODEL_SAVE_DIRECTORY             = 'Tensorboard/Current/' # where to save all data
        
    TENSORBOARD_FILE_EXTENSION           = '.tensorboard' # file extension for tensorboard file
    SAVE_CHECKPOINT_EVERY_NUM_ITERATIONS = 10000 # how often to save the neural network parameters
    NUM_CHECKPOINT_MODELS_TO_SAVE        = 5 # How many of the most recent policy models to keep before discarding
