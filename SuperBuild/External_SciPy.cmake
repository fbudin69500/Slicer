
set(proj SciPy)

# Set dependency list
set(${proj}_DEPENDENCIES python python-setuptools NUMPY python-cython)

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  message(FATAL_ERROR "Enabling ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj} is not supported !")
endif()

set(SciPy_REPOSITORY ${git_protocol}://github.com/scipy/scipy.git)
set(SciPy_GIT_TAG 0c44e977973b4c92dc1a5c235b9380f5b11ec45d)

  # environment
  set(_env_script ${CMAKE_BINARY_DIR}/${proj}_Env.cmake)
  ExternalProject_Write_SetBuildEnv_Commands(${_env_script})
  ExternalProject_Write_SetPythonSetupEnv_Commands(${_env_script} APPEND)
  file(APPEND ${_env_script})

# build step
  set(_build_script ${CMAKE_BINARY_DIR}/${proj}_build_step.cmake)
  file(WRITE ${_build_script}
"include(\"${_env_script}\")
set(${proj}_WORKING_DIR \"${CMAKE_BINARY_DIR}/${proj}\")
ExternalProject_Execute(${proj} \"build\" \"${PYTHON_EXECUTABLE}\" setup.py build)
")

# install step
  set(_install_script ${CMAKE_BINARY_DIR}/${proj}_install_step.cmake)
  file(WRITE ${_install_script}
"include(\"${_env_script}\")
set(${proj}_WORKING_DIR \"${CMAKE_BINARY_DIR}/${proj}\")
ExternalProject_Execute(${proj} \"install\" \"${PYTHON_EXECUTABLE}\" setup.py install)
")

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY ${SciPy_REPOSITORY}
  GIT_TAG ${SciPy_GIT_TAG}
  SOURCE_DIR ${proj}
  CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -P ${_build_script}
    INSTALL_COMMAND ${CMAKE_COMMAND} -P ${_install_script}
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )

