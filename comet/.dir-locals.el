;; this file automatically sets the below variables in an emacs session visiting
;; this directory, to tell rspec-mode how to run specs in our docker environment.
;;
;; See https://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html
;; See https://github.com/pezra/rspec-mode#docker
((nil . ((rspec-use-docker-when-possible . t)
         (rspec-docker-cwd . "/app/samvera/hyrax-webapp/")
         (rspec-docker-container . "web"))))
