if [ ! -d "~/.zshrc" ]; then
  SHELL_FILE=~/.zshrc
else
   SHELL_FILE=~/.bashrc
fi

echo "Installing scripts on PATH in $SHELL_FILE"
echo '#--- scripts installation ---' >> $SHELL_FILE
echo PATH='~/git/scripts/bin/kotlin:${PATH}' >> $SHELL_FILE
echo PATH='~/git/scripts/bin/git:${PATH}' >> $SHELL_FILE
echo PATH='~/git/scripts/bin/kubernetes:${PATH}' >> $SHELL_FILE
echo PATH='~/git/scripts/bin/node:${PATH}' >>$SHELL_FILE
echo PATH='~/git/scripts/bin/auth:${PATH}' >>$SHELL_FILE
echo PATH='~/git/scripts/bin/circle:${PATH}' >>$SHELL_FILE
echo PATH='~/git/scripts/bin/sqs:${PATH}' >>$SHELL_FILE
echo PATH='~/git/scripts/bin/dns:${PATH}' >>$SHELL_FILE
echo 'export PATH' >> $SHELL_FILE
echo '#--- scripts installation ---' >> $SHELL_FILE

source $SHELL_FILE
echo "Path value: $PATH"
