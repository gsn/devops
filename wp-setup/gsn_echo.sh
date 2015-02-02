# Define echo function
# Blue color
function gsn_lib_echo()
{
  echo $(tput setaf 4)$@$(tput sgr0)
}

# White color
function gsn_lib_echo_info()
{
  echo $(tput setaf 7)$@$(tput sgr0)
}

# Red color
function gsn_lib_echo_fail()
{
  echo $(tput setaf 1)$@$(tput sgr0)
}

function gsn_lib_error()
{
  echo $(tput setaf 1)$@$(tput sgr0)
}
