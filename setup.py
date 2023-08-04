import setuptools

setuptools.setup(
    author="Allen Goodman",
    author_email="allen.goodman@icloud.com",
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
    ],
    extras_require={
        "dev": [
            "black==19.10b0",
            "click>=7.1.2",
            "pre-commit==2.2.0",
            "sphinx==3.1.2",
            "twine==3.1.1",
        ],
        "test": ["pytest==5.4.1", "pytest-timeout==2.1.0"],
        "wx": ["wxPython==4.2.0"],
    },
    install_requires=[
        "boto3>=1.12.28",
        "centrosome==1.2.2",
        "docutils==0.15.2",
        "future>=0.18.2",
        "fsspec>=2021.11.0",
        "h5py~=3.6.0",
        "lxml>=4.6.4",
        "matplotlib>=3.1.3",
        "numpy>=1.18.2",
        "psutil>=5.7.0",
        "pyzmq~=22.3",
        "scikit-image>=0.16.2",
        "scipy>=1.4.1",
        "scyjava>=1.6.0",
        "zarr>=2.10",
        "google-cloud-storage>=2.6.0",
    ],
    license="BSD",
    name="cellprofiler-core",
    package_data={"cellprofiler_core": ["py.typed"]},
    packages=setuptools.find_packages(exclude=["tests"]),
    python_requires=">=3.8",
    url="https://github.com/CellProfiler/core",
    version="5.0.0",
    zip_safe=False,
)
