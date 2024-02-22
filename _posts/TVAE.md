## Introduction 

Autoencoders are a type of artificial neural network used for learning efficient representations of data. They consist of an encoder network that maps the input data into a latent space representation and a decoder network that reconstructs the input data from the latent space. Variational autoencoders (VAEs) are a specific type of autoencoder that is trained to generate new data samples from the learned latent space in a way that ensures continuity and smoothness of the generated samples.

VAEs can be used for synthetic data generation by sampling from the learned latent space to produce new, artificial data that resembles the original data. This is particularly useful for imbalanced learning, where the VAE can be used to generate synthetic data for the minority class, addressing the imbalance in the dataset.

The use of VAEs for synthetic data generation is also relevant in financial applications, where they can be employed to generate synthetic tabular data for various analytical purposes.

In summary, VAEs are a powerful tool for synthetic data generation, as they can learn complex representations of the input data and generate new samples that retain the characteristics of the original data.

Variational Autoencoders (VAEs) represent a sophisticated class of generative models in machine learning, operating within the broader family of autoencoders. Unlike conventional autoencoders, VAEs excel in learning latent space representations of input data while simultaneously enabling the generation of novel data points based on this acquired knowledge. The architecture of a VAE comprises two core components: an encoder and a decoder. The encoder processes input data and maps it to a latent space, where each point in this space signifies a distribution of potential inputs. Subsequently, the decoder reconstructs the input from a selected point in the latent space, producing an output that closely mirrors the original input data.

Central to the functionality of VAEs is the notion of the latent space representation. Through extensive training, VAEs learn to capture the underlying structure and variations present in the input data, condensing it into a continuous, low-dimensional space. This latent space encapsulates the essential characteristics of the dataset, facilitating the generation of new data points that exhibit similar traits to those observed in the original dataset. By sampling from diverse regions within the latent space and decoding these samples, VAEs can generate synthetic data points that adhere to the statistical properties of the input data.

In practical applications, VAEs find utility in various domains, including image and text generation, as well as molecular design. In healthcare, for instance, VAEs can learn the statistical distributions of patient data and produce synthetic patient records that preserve key characteristics while safeguarding privacy. Furthermore, VAEs contribute to data augmentation efforts by generating synthetic data points to supplement existing datasets, thereby enhancing the performance of machine learning models. Overall, Variational Autoencoders stand as versatile tools for synthetic data generation, leveraging their ability to capture underlying data distributions to generate realistic and diverse synthetic data across a multitude of applications.

Variational autoencoder is another neural network generative model. We adapt VAE to tabular data by using the same preprocessing and modifying the loss function. We call this model TVAE. In TVAE, we use two neural networks to model p (rj jzj) and q (zj jrj), and train them using evidence lower-bound (ELBO) loss. 

This code implements the TVAE model for synthetic data generation. TVAE consists of an encoder and a decoder, where the encoder compresses the input data into a lower-dimensional latent space, and the decoder reconstructs the original data from this latent representation.

The `Encoder` class defines the encoder component of the TVAE model. It takes as input the dimensions of the data, the size of each hidden layer (`compress_dims`), and the size of the output vector (`embedding_dim`). The encoder applies a sequence of linear transformations followed by ReLU activation functions to map the input data to the latent space. It then outputs the mean (`mu`), standard deviation (`std`), and logarithm of the variance (`logvar`) of the latent representation.

The `Decoder` class defines the decoder component of the TVAE model. It takes as input the size of the input vector (`embedding_dim`), the size of each hidden layer (`decompress_dims`), and the dimensions of the original data. Similar to the encoder, the decoder applies a sequence of linear transformations followed by ReLU activation functions to reconstruct the original data from the latent space. Additionally, it outputs the standard deviation (`sigma`) of the reconstruction.

The `_loss_function` function calculates the loss function used for training the TVAE model. It computes the reconstruction loss and the Kullback-Leibler divergence loss, which measures the difference between the learned latent distribution and a standard normal distribution.

The `TVAE` class encapsulates the entire TVAE model. It provides methods for fitting the model to training data (`fit`) and sampling synthetic data (`sample`). During training, the encoder and decoder are optimized using the Adam optimizer. The training process minimizes the reconstruction loss and the Kullback-Leibler divergence loss to learn a latent representation of the input data. Finally, the `set_device` method allows users to specify whether to use GPU or CPU for computation.



Below is the pseudo code for the [TVAE algorithm](https://github.com/sdv-dev/CTGAN/blob/main/ctgan/synthesizers/tvae.py) can be outlined as follows:

```python
1. Instantiate TVAE with hyperparameters
2. Fit TVAE model to training data
3. Generate synthetic data using TVAE model

Initialize TVAE algorithm with hyperparameters:
- embedding_dim
- compress_dims
- decompress_dims


Define Encoder class:
- Initialize with data_dim, compress_dims, embedding_dim
- Define forward method to encode input data

Define Decoder class:
- Initialize with embedding_dim, decompress_dims, data_dim
- Define forward method to decode input data

Define loss_function to compute loss:
- Compute reconstruction loss and divergence loss

Define TVAE class:
- Initialize with hyperparameters
- Define fit method to train the TVAE model:
  - Transform input data
  - Initialize Encoder and Decoder
  - Iterate through epochs:
    - Iterate through batches:
      - Compute encoder output
      - Compute decoder output
      - Compute loss
      - Update model parameters

Define sample method to generate synthetic data:
  - Generate synthetic data based on input samples

```
Here's a breakdown of each step:

Breakdown of each step based on the provided pseudo code:

1. **Encoder Class (Initialization and Forward Pass)**:
   - Initialize the Encoder class with data_dim, compress_dims, and embedding_dim.
   - Inside the `__init__` method, construct a sequence of linear layers followed by ReLU activation functions based on the compress_dims.
   - Then, define two linear layers (`fc1` and `fc2`) to produce the mean (mu) and log variance (logvar) of the latent space.
   - Implement the `forward` method to encode the input data, where the input passes through the sequential layers, and then produces mu, std (standard deviation), and logvar.

2. **Decoder Class (Initialization and Forward Pass)**:
   - Initialize the Decoder class with embedding_dim, decompress_dims, and data_dim.
   - Inside the `__init__` method, construct a sequence of linear layers followed by ReLU activation functions based on the decompress_dims.
   - Add a linear layer at the end to produce the output data.
   - Additionally, create a sigma parameter to model the uncertainty of the reconstructed data.
   - Implement the `forward` method to decode the input vector, where the input passes through the sequential layers to produce the reconstructed data and sigma.

3. **Loss Function**:
   - Define a loss function `_loss_function` to compute the reconstruction loss and Kullback-Leibler divergence loss.
   - Iterate over the output_info to compute the loss for each column of the data based on whether it has softmax activation or not.
   - Compute the reconstruction loss and Kullback-Leibler divergence loss, and return their sum.

4. **TVAE Class (Initialization, Fit, Sample, and Set Device)**:
   - Initialize the TVAE class with various hyperparameters including embedding_dim, compress_dims, decompress_dims, etc.
   - Define the `fit` method to train the TVAE model on the input data:
     - Transform the input data using the DataTransformer.
     - Create a DataLoader for batch training.
     - Initialize Encoder and Decoder.
     - Define an optimizer for Encoder and Decoder.
     - Iterate through epochs and batches, compute encoder and decoder outputs, compute loss, and update model parameters accordingly.
   - Define the `sample` method to generate synthetic data similar to the training data using the trained Decoder:
     - Generate noise vectors, pass them through the Decoder, and transform the generated data back to the original space.
   - Define the `set_device` method to specify the device (GPU or CPU) for computation.

## Clover implementation 

    """
    Also a wrapper of a data synthesizer available in the SDV package.
    The synthesizer is TVAE, a VAE for tabular data.
    https://github.com/sdv-dev

    :param df: the data to synthesize
    :param metadata: a dictionary containing the list of **continuous** and **categorical** variables
    :param random_state: for reproducibility purposes
    :param generator_filepath: the path of the generator to sample from if it exists
    :param discriminator_steps: the number of discriminator updates to do for each generator update.
    :param epochs: the number of training epochs.
    :param batch_size: the batch size for training.
    :param compress_dims: the size of the hidden layers in the encoder.
    :param decompress_dims: the size of the hidden layers in the decoder.
    """
    Steps include:
    Preparing the parameters to train the generator.
    Train the generator and save it.
    Generate samples using the synthesizer trained on the real data.


### References 

- https://github.com/sdv-dev/SDV
- https://sdv.dev/SDV/user_guides/single_table/tvae.html
- https://github.com/sdv-dev/SDV/blob/main/sdv/single_table/ctgan.py
- https://github.com/sdv-dev/CTGAN/blob/main/ctgan/synthesizers/tvae.py
- https://docs.sdv.dev/sdv/single-table-data/modeling/synthesizers/tvaesynthesizer
- https://arxiv.org/pdf/1907.00503.pdf
- https://arxiv.org/abs/1312.6114
- "Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow, 3rd Edition” chapitre 17 

- https://ieeexplore.ieee.org/document/8285168
- https://www.mdpi.com/1999-4893/16/2/121
- https://ydata.ai/resources/why-synthetic-data-for-data-sharing
- https://github.com/nhsx/SynthVAE
- https://visualstudiomagazine.com/articles/2021/05/06/variational-autoencoder.aspx
