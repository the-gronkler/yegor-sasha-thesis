<?php

namespace App\Console\Helpers;

use Symfony\Component\Console\Output\OutputInterface;

class ConsoleOutputHelper
{
    private OutputInterface $output;

    public function __construct(OutputInterface $output)
    {
        $this->output = $output;
    }

    /**
     * Run a simple task with start/complete messages.
     */
    public function runSimpleTask(string $message, callable $task): void
    {
        $this->output->writeln($message);
        $task();
        $this->output->writeln('<info>   ✓ Completed</info>');
        $this->output->writeln('');
    }

    /**
     * Run a task with a progress bar.
     */
    public function runWithProgressBar(string $label, int $total, string $itemType, callable $task): void
    {
        $this->output->writeln($label);

        $bar = $this->output->createProgressBar($total);
        $bar->setFormat(' %current%/%max% [%bar%] %percent:3s%% %message%');
        $bar->setMessage('Starting...');
        $bar->start();

        $task(function ($current, $total) use ($bar, $itemType) {
            $bar->setMessage("{$itemType} {$current}/{$total}");
            $bar->setProgress($current);
        });

        $bar->setMessage('Complete');
        $bar->finish();
        $this->output->writeln('');
    }
}
