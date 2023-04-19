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
                        dir("build/Debug") {
                            sh "ctest --output-on-failure"
                            sh "mkdir coverage"
                            sh "lcov -t 'sam2p' -c -d CMakeFiles/sam2p.dir/ -o coverage/sam2p.info"
                            sh "genhtml -o coverage/report coverage/sam2p.info"
                        }
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
