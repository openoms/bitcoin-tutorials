# Run the nokyc scripts in every 10 minutes in a tmux window

Using:
* https://github.com/j4imefoo/nokyc
* https://github.com/tmuxinator/tmuxinator


## Install
```
sudo apt-get install tmux git rubygems -y

cd
git clone https://github.com/j4imefoo/nokyc
cd nokyc
pip install -r requirements.txt

# install https://github.com/tmuxinator/tmuxinator
sudo gem install tmuxinator
sudo wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.bash -O /etc/bash_completion.d/tmuxinator.bash
echo "export EDITOR=$(which nano)" >> ~/.bashrc

# tmuxinator config
echo "\
name: nokyc
root: ~/nokyc/

windows:
  - nokyc:
      layout: even-vertical
      panes:
      - buyeur:
        - while ./nokyc.py -f eur -t buy -d 5; do sleep 600; done
      - buygbp:
        - while ./nokyc.py -f gbp -t buy -d 5; do sleep 600; done
      - sellgbp:
        - while ./nokyc.py -f gbp -t sell -d 5; do sleep 600; done
" | tee ~/.config/tmuxinator/nokyc.yml
```

## Start
```
bash
mux s nokyc
```
## Exit window
```
CTRL+B -> & , y
```