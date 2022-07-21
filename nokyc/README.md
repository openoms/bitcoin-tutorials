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


[DEFAULT]
# Local port where tor is running. 9050 for tor daemon, 9150 for tor browser
TOR_PORT = 9050

# Payment methods to avoid. In lower case.
avoid_methods = ["ripple", "litecoin", "ethereum", "satispay", "f2f", "paypal", "cardano", "hal-cash", "sepa_instant", "binance smart chain (bsc)", "amazon fr giftcard"]


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
`CTRL+b` -> `&` -> `y`
