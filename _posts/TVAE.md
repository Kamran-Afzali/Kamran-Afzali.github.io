## Introduction 

Autoencoders are a type of artificial neural network used for learning efficient representations of data. They consist of an encoder network that maps the input data into a latent space representation and a decoder network that reconstructs the input data from the latent space. Variational autoencoders (VAEs) are a specific type of autoencoder that is trained to generate new data samples from the learned latent space in a way that ensures continuity and smoothness of the generated samples.

VAEs can be used for synthetic data generation by sampling from the learned latent space to produce new, artificial data that resembles the original data. This is particularly useful for imbalanced learning, where the VAE can be used to generate synthetic data for the minority class, addressing the imbalance in the dataset.

The use of VAEs for synthetic data generation is also relevant in financial applications, where they can be employed to generate synthetic tabular data for various analytical purposes.

In summary, VAEs are a powerful tool for synthetic data generation, as they can learn complex representations of the input data and generate new samples that retain the characteristics of the original data.

Variational Autoencoders (VAEs) represent a sophisticated class of generative models in machine learning, operating within the broader family of autoencoders. Unlike conventional autoencoders, VAEs excel in learning latent space representations of input data while simultaneously enabling the generation of novel data points based on this acquired knowledge. The architecture of a VAE comprises two core components: an encoder and a decoder. The encoder processes input data and maps it to a latent space, where each point in this space signifies a distribution of potential inputs. Subsequently, the decoder reconstructs the input from a selected point in the latent space, producing an output that closely mirrors the original input data.

Central to the functionality of VAEs is the notion of the latent space representation. Through extensive training, VAEs learn to capture the underlying structure and variations present in the input data, condensing it into a continuous, low-dimensional space. This latent space encapsulates the essential characteristics of the dataset, facilitating the generation of new data points that exhibit similar traits to those observed in the original dataset. By sampling from diverse regions within the latent space and decoding these samples, VAEs can generate synthetic data points that adhere to the statistical properties of the input data.

In practical applications, VAEs find utility in various domains, including image and text generation, as well as molecular design. In healthcare, for instance, VAEs can learn the statistical distributions of patient data and produce synthetic patient records that preserve key characteristics while safeguarding privacy. Furthermore, VAEs contribute to data augmentation efforts by generating synthetic data points to supplement existing datasets, thereby enhancing the performance of machine learning models. Overall, Variational Autoencoders stand as versatile tools for synthetic data generation, leveraging their ability to capture underlying data distributions to generate realistic and diverse synthetic data across a multitude of applications.

Below is the pseudo code for the Private-PGM algorithm can be outlined as follows:

```python

```
Here's a breakdown of each step:


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
- https://docs.sdv.dev/sdv/single-table-data/modeling/synthesizers/tvaesynthesizer
- https://arxiv.org/pdf/1907.00503.pdf
- https://arxiv.org/abs/1312.6114
- "Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow, 3rd Edition” chapitre 17 

- https://ieeexplore.ieee.org/document/8285168
- https://www.mdpi.com/1999-4893/16/2/121
- https://ydata.ai/resources/why-synthetic-data-for-data-sharing
- https://github.com/nhsx/SynthVAE
- https://visualstudiomagazine.com/articles/2021/05/06/variational-autoencoder.aspx
