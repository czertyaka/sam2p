pipeline {
    agent none
    stages {
        stage("Build") {
            agent {
                dockerfile {
                    filename "ci/gcc.Dockerfile"
                }
            }
            stages {
                stage("Release") {
                    steps {
                        sh "cmake -B build/Release ."
                        sh "cmake --build build/Release --target sam2p -j \$(nproc)"
                    }
                }
                stage("Debug") {
                    steps {
                        sh "cmake -B build/Debug . -DCMAKE_BUILD_TYPE=Debug"
                        sh "cmake --build build/Debug --target sam2p -j \$(nproc)"
                    }
                }
                stage("Tests") {
                    steps {
                        sh "ctest --test-dir build/Debug --output-on-failure"
                    }
                }
            }
        }
        stage("Fuzzing") {
            agent {
                docker {
                    image "aflplusplus/aflplusplus"
                }
            }
            steps {
                sh "cmake -B build . -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_COMPILER=afl-c++"
                sh "AFL_USE_ASAN=1 cmake --build build --target sam2p -j \$(nproc)"
            }
        }
    }
}
